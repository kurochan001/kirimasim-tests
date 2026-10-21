/* VPI application of test_vpi_typespec_relations (IEEE 1800-2023 37.22, 37.24, 37.25). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_typespec_relations"
#define MAX 8

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static const char *kind(vpiHandle t)
{
    if (t == NULL)
        return "none";
    switch (vpi_get(vpiType, t)) {
    case vpiArrayTypespec: return "array typespec";
    case vpiLogicTypespec: return "logic typespec";
    case vpiIntTypespec: return "int typespec";
    case vpiTimeTypespec: return "time typespec";
    case vpiRealTypespec: return "real typespec";
    case vpiStructTypespec: return "struct typespec";
    default: return "other typespec";
    }
}

/* Prints the bounds of the leftmost range, given by vpiLeftRange and vpiRightRange. */
static void bounds(vpiHandle h)
{
    vpiHandle l = vpi_handle(vpiLeftRange, h), r = vpi_handle(vpiRightRange, h);
    if (l == NULL && r == NULL)
        vpi_printf((PLI_BYTE8 *)"none");
    else if (l == NULL || r == NULL)
        vpi_printf((PLI_BYTE8 *)"one bound missing");
    else
        vpi_printf((PLI_BYTE8 *)"%d:%d", int_value(l), int_value(r));
}

/* Prints each range of the vpiRange iteration, with the size of an empty one. */
static void ranges(vpiHandle t)
{
    vpiHandle it = vpi_iterate(vpiRange, t), r;
    int first = 1;
    vpi_printf((PLI_BYTE8 *)", ranges:");
    while (it != NULL && (r = vpi_scan(it)) != NULL) {
        vpi_printf((PLI_BYTE8 *)"%s ", first ? "" : ",");
        bounds(r);
        /* 37.22 detail 2 fixes the size of an empty range only. */
        if (vpi_handle(vpiLeftRange, r) == NULL && vpi_handle(vpiRightRange, r) == NULL)
            vpi_printf((PLI_BYTE8 *)" (size %d)", (int)vpi_get(vpiSize, r));
        first = 0;
    }
}

static vpiHandle typespec_of(const char *name)
{
    char full[64];
    vpiHandle h;
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name(full, NULL);
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s not found\n", name);
    return h != NULL ? vpi_handle(vpiTypespec, h) : NULL;
}

static void unwind(void)
{
    vpiHandle t = typespec_of("grid");
    int level = 0;

    if (t == NULL)
        return;
    vpi_printf((PLI_BYTE8 *)"grid: %s, name %s, range ", kind(t), name_of(t));
    bounds(t);
    ranges(t);
    vpi_printf((PLI_BYTE8 *)"\n");
    while (t != NULL && level < 6) {
        t = vpi_handle(vpiElemTypespec, t);
        level++;
        vpi_printf((PLI_BYTE8 *)" element %d: %s", level, kind(t));
        if (t != NULL)
            vpi_printf((PLI_BYTE8 *)", name %s", name_of(t));
        if (t != NULL && vpi_handle(vpiElemTypespec, t) != NULL) {
            vpi_printf((PLI_BYTE8 *)", range ");
            bounds(t);
        }
        vpi_printf((PLI_BYTE8 *)"\n");
    }
}

static void arrays(void)
{
    vpiHandle da = typespec_of("da"), aa = typespec_of("aa"), aw = typespec_of("aw"), idx;

    if (da != NULL) {
        vpi_printf((PLI_BYTE8 *)"da: %s, range ", kind(da));
        bounds(da);
        ranges(da);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    if (aa != NULL) {
        idx = vpi_handle(vpiIndexTypespec, aa);
        vpi_printf((PLI_BYTE8 *)"aa: %s, index typespec %s", kind(aa), kind(idx));
        ranges(aa);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    if (aw != NULL)
        vpi_printf((PLI_BYTE8 *)"aw: %s, index typespec %s\n", kind(aw),
                   kind(vpi_handle(vpiIndexTypespec, aw)));
}

static void aliases_and_members(void)
{
    vpiHandle t = typespec_of("when"), ds = typespec_of("ds"), alias, it, m, e;
    char list[MAX][32];
    int n = 0, i;

    if (t != NULL) {
        alias = vpi_handle(vpiTypedefAlias, t);
        vpi_printf((PLI_BYTE8 *)"when: %s, name %s, alias: %s, name %s\n", kind(t), name_of(t),
                   kind(alias), name_of(alias));
    }
    if (ds != NULL) {
        it = vpi_iterate(vpiTypespecMember, ds);
        while (it != NULL && (m = vpi_scan(it)) != NULL) {
            if (n == MAX)
                continue;
            /* Only a has an explicit default (detail 7); b gets no check. */
            e = strcmp(name_of(m), "a") == 0 ? vpi_handle(vpiExpr, m) : NULL;
            if (e != NULL)
                snprintf(list[n++], sizeof list[0], "%s default %d", name_of(m), int_value(e));
            else
                snprintf(list[n++], sizeof list[0], "%s", name_of(m));
        }
        qsort(list, n, sizeof list[0], by_text);
        vpi_printf((PLI_BYTE8 *)"ds: %s, name %s, members:", kind(ds), name_of(ds));
        for (i = 0; i < n; i++)
            vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", list[i]);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
}

static void interconnect(void)
{
    vpiHandle ic = vpi_handle_by_name((PLI_BYTE8 *)TOP ".ic", NULL), ts, it, m;
    char list[MAX][16];
    int n = 0, i;

    if (ic == NULL) {
        vpi_printf((PLI_BYTE8 *)"ic not found\n");
        return;
    }
    ts = vpi_handle(vpiTypespec, ic);
    it = vpi_iterate(vpiMember, ic);
    while (it != NULL && (m = vpi_scan(it)) != NULL)
        if (n < MAX)
            snprintf(list[n++], sizeof list[0], "%s", name_of(m));
    qsort(list, n, sizeof list[0], by_text);
    vpi_printf((PLI_BYTE8 *)"ic: interconnect net %d, typespec %s, name %s, members:",
               vpi_get(vpiType, ic) == vpiInterconnectNet, kind(ts), name_of(ts));
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", list[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 typespecs_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    unwind();
    arrays();
    aliases_and_members();
    interconnect();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_typespecs";
    d.calltf = typespecs_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
