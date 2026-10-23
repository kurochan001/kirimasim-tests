/* VPI application of test_vpi_net_members_elements_parents (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_members_elements_parents"
#define MAX 8

enum { FULL = 1, INDICES = 2, PACKED = 4 };

struct item {
    char *name;
    vpiHandle h;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int int_value(vpiHandle expr)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(expr, &v);
    return (int)v.value.integer;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiNet: return "logic net";
    case vpiStructNet: return "struct net";
    case vpiUnionNet: return "union net";
    case vpiArrayNet: return "array net";
    case vpiPackedArrayNet: return "packed array net";
    default: return "other type";
    }
}

static void describe(vpiHandle h, int what)
{
    vpiHandle p = vpi_handle(vpiParent, h), it, x;

    vpi_printf("%s %s", kind(h), copy(vpi_get_str(vpiName, h)));
    if (what & FULL) {
        vpi_printf(", full name %s", copy(vpi_get_str(vpiFullName, h)));
        vpi_printf(", decompiled %s", copy(vpi_get_str(vpiDecompile, h)));
    }
    vpi_printf(", parent %s", p ? copy(vpi_get_str(vpiName, p)) : "NULL");
    vpi_printf(", struct/union member %d", (int)vpi_get(vpiStructUnionMember, h));
    if (what & PACKED)
        vpi_printf(", packed array member %d, array member %d",
                   (int)vpi_get(vpiPackedArrayMember, h), (int)vpi_get(vpiArrayMember, h));
    if (what & INDICES) {
        vpi_printf(", indices");
        it = vpi_iterate(vpiIndex, h);
        if (it == NULL)
            vpi_printf(" NULL");
        while (it && (x = vpi_scan(it)) != NULL)
            vpi_printf(" %d", int_value(x));
    }
    vpi_printf("\n");
}

static int collect(vpiHandle ref, PLI_INT32 type, struct item *list)
{
    vpiHandle it = ref ? vpi_iterate(type, ref) : NULL, h;
    int n = 0;
    while (it && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = copy(vpi_get_str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    return n;
}

static void each(const char *label, vpiHandle ref, PLI_INT32 type, int what)
{
    struct item list[MAX];
    int n = collect(ref, type, list), i;
    vpi_printf("%s: %d\n", label, n);
    for (i = 0; i < n; i++) {
        vpi_printf("  ");
        describe(list[i].h, what);
    }
}

static vpiHandle find(vpiHandle ref, PLI_INT32 type, const char *name)
{
    struct item list[MAX];
    int n = collect(ref, type, list), i;
    for (i = 0; i < n; i++)
        if (strcmp(list[i].name, name) == 0)
            return list[i].h;
    return NULL;
}

static PLI_INT32 members_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle su = vpi_handle_by_name((PLI_BYTE8 *)TOP ".su", NULL);
    vpiHandle pu = vpi_handle_by_name((PLI_BYTE8 *)TOP ".pu", NULL);
    vpiHandle pa = vpi_handle_by_name((PLI_BYTE8 *)TOP ".pa", NULL);
    vpiHandle inner, m, by_full, by_decompiled, pa1, pa10;

    (void)user_data;
    if (su == NULL || pu == NULL || pa == NULL) {
        vpi_printf("nets not found\n");
        return 0;
    }
    describe(su, 0);
    each("members of su", su, vpiMember, FULL);
    inner = find(su, vpiMember, "inner");
    each("members of su.inner", inner, vpiMember, FULL);
    m = find(inner, vpiMember, "m");
    by_full = vpi_handle_by_name((PLI_BYTE8 *)TOP ".su.inner.m", NULL);
    by_decompiled = vpi_handle_by_name((PLI_BYTE8 *)"su.inner.m", top);
    vpi_printf("su.inner.m by full name from the top %d, by decompiled name in the module %d\n",
               m != NULL && by_full != NULL && vpi_compare_objects(m, by_full),
               m != NULL && by_decompiled != NULL && vpi_compare_objects(m, by_decompiled));
    each("members of pu", pu, vpiMember, 0);
    describe(pa, PACKED);
    each("elements of pa", pa, vpiElement, PACKED | INDICES);
    pa1 = find(pa, vpiElement, "pa[1]");
    each("elements of pa[1]", pa1, vpiElement, FULL | PACKED | INDICES);
    pa10 = find(pa1, vpiElement, "pa[1][0]");
    each("members of pa[1][0]", pa10, vpiMember, FULL);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_members";
    d.calltf = members_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
