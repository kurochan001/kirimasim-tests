/* VPI application of test_vpi_select_objects_event_arrays (IEEE 1800-2023
 * 37.19, 37.58, 37.27). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_select_objects_event_arrays"
#define MAX 8

static int int_of(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int same(vpiHandle a, vpiHandle b)
{
    return a && b ? (int)vpi_compare_objects(a, b) : 0;
}

static vpiHandle find(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name(full, NULL);
}

static void indices(vpiHandle h)
{
    vpiHandle it = vpi_iterate(vpiIndex, h), ix;
    vpi_printf(", indices:");
    while (it && (ix = vpi_scan(it)) != NULL)
        vpi_printf(" %d", int_of(ix));
}

static const char *parent_kind(vpiHandle p)
{
    if (p == NULL)
        return "none";
    switch (vpi_get(vpiType, p)) {
    case vpiIntegerVar: return "integer var";
    case vpiParameter: return "parameter";
    case vpiVarSelect: return "var select";
    default: return "other type";
    }
}

static void bit_select(const char *label, vpiHandle h)
{
    vpiHandle p;
    if (h == NULL || vpi_get(vpiType, h) != vpiBitSelect) {
        vpi_printf("%s: not a bit-select\n", label);
        return;
    }
    p = vpi_handle(vpiParent, h);
    vpi_printf("%s: bit-select, parent %s", label, parent_kind(p));
    if (p && vpi_get(vpiType, p) == vpiVarSelect)
        vpi_printf(" with constant select %d", (int)vpi_get(vpiConstantSelect, p));
    vpi_printf(", index %d", int_of(vpi_handle(vpiIndex, h)));
    if (!p || vpi_get(vpiType, p) != vpiParameter)
        vpi_printf(", constant select %d", (int)vpi_get(vpiConstantSelect, h));
    vpi_printf(", value %d\n", int_of(h));
}

static int by_text(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}

/* The kinds of the objects that vpiUse gives for h, sorted. */
static void uses(const char *label, vpiHandle h)
{
    const char *kinds[MAX];
    vpiHandle it = h ? vpi_iterate(vpiUse, h) : NULL, u;
    int n = 0, i;
    while (it && (u = vpi_scan(it)) != NULL) {
        const char *k;
        switch (vpi_get(vpiType, u)) {
        case vpiContAssign:
        case vpiContAssignBit: k = "cont assign"; break;
        case vpiPrimTerm: k = "prim term"; break;
        default: k = "other"; break;
        }
        if (n < MAX)
            kinds[n++] = k;
    }
    qsort(kinds, n, sizeof kinds[0], by_text);
    vpi_printf("uses of %s:", label);
    for (i = 0; i < n; i++)
        vpi_printf("%s %s", i ? "," : "", kinds[i]);
    vpi_printf("\n");
}

/* The right-hand side of the continuous assignment to the named net. */
static vpiHandle rhs_of(const char *lhs_name)
{
    vpiHandle mod = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), it, ca, rhs = NULL;
    it = mod ? vpi_iterate(vpiContAssign, mod) : NULL;
    while (it && (ca = vpi_scan(it)) != NULL) {
        vpiHandle lhs = vpi_handle(vpiLhs, ca);
        PLI_BYTE8 *s = lhs ? vpi_get_str(vpiName, lhs) : NULL;
        if (s && strcmp(s, lhs_name) == 0)
            rhs = vpi_handle(vpiRhs, ca);
    }
    return rhs;
}

static const char *typespec_kind(vpiHandle h)
{
    vpiHandle ts = h ? vpi_handle(vpiTypespec, h) : NULL;
    if (ts == NULL)
        return "none";
    switch (vpi_get(vpiType, ts)) {
    case vpiEventTypespec: return "event typespec";
    case vpiArrayTypespec: return "array typespec";
    default: return "other typespec";
    }
}

static void selects(vpiHandle call)
{
    vpiHandle it = vpi_iterate(vpiArgument, call), arg[6];
    vpiHandle m2 = find("m2"), dyn = find("dyn");
    int n = 0;
    while (it && n < 6 && (arg[n] = vpi_scan(it)) != NULL)
        n++;
    if (it && n == 6)
        vpi_release_handle(it);
    if (n != 6) {
        vpi_printf("expected 6 arguments, got %d\n", n);
        return;
    }
    if (vpi_get(vpiType, arg[0]) != vpiVarSelect) {
        vpi_printf("m2[1][2]: not a var select\n");
    } else {
        vpi_printf("m2[1][2]: var select, parent is m2 %d, size %d",
                   same(vpi_handle(vpiParent, arg[0]), m2), (int)vpi_get(vpiSize, arg[0]));
        indices(arg[0]);
        vpi_printf(", constant select %d, value %d\n",
                   (int)vpi_get(vpiConstantSelect, arg[0]), int_of(arg[0]));
    }
    if (vpi_get(vpiType, arg[1]) != vpiVarSelect)
        vpi_printf("dyn[1]: not a var select\n");
    else
        vpi_printf("dyn[1]: var select, parent is dyn %d, constant select %d\n",
                   same(vpi_handle(vpiParent, arg[1]), dyn),
                   (int)vpi_get(vpiConstantSelect, arg[1]));
    bit_select("iv[3]", arg[2]);
    bit_select("P[2]", arg[3]);
    bit_select("mv[k][1][5]", arg[4]);
    bit_select("mv[2][1][5]", arg[5]);
}

static void events(void)
{
    vpiHandle ea = find("ea"), ev = find("ev"), it, r, el;
    PLI_INT32 idx[2] = {1, 3};
    int first = 1;
    if (ea == NULL || ev == NULL) {
        vpi_printf("ea or ev not found\n");
        return;
    }
    vpi_printf("ea: named event array %d, ranges:",
               vpi_get(vpiType, ea) == vpiNamedEventArray);
    it = vpi_iterate(vpiRange, ea);
    while (it && (r = vpi_scan(it)) != NULL) {
        vpi_printf("%s %d:%d", first ? "" : ",", int_of(vpi_handle(vpiLeftRange, r)),
                   int_of(vpi_handle(vpiRightRange, r)));
        first = 0;
    }
    vpi_printf("\n");
    el = vpi_handle_by_multi_index(ea, 2, idx);
    if (el == NULL) {
        vpi_printf("ea[1][3]: NULL\n");
    } else {
        vpi_printf("ea[1][3]: named event %d, parent is ea %d",
                   vpi_get(vpiType, el) == vpiNamedEvent, same(vpi_handle(vpiParent, el), ea));
        indices(el);
        vpi_printf("\n");
    }
    vpi_printf("ev: index iteration is NULL %d\n", vpi_iterate(vpiIndex, ev) == NULL);
    vpi_printf("typespecs: ev %s, ea %s\n", typespec_kind(ev), typespec_kind(ea));
}

static PLI_INT32 selects_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    selects(vpi_handle(vpiSysTfCall, NULL));
    uses("u", find("u"));
    uses("u[2]", rhs_of("y2"));
    events();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_selects";
    d.calltf = selects_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
