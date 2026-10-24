/* VPI application of test_vpi_param_assign_defparam (IEEE 1800-2023 37.28). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_param_assign_defparam"
#define MAX 8

struct item {
    char *name;
    vpiHandle h;
};

/* vpi_get_str reuses its buffer (38.11), so every string is copied; NULL is shown. */
static char *str(PLI_BYTE8 *s)
{
    const char *t = s ? s : "NULL";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *kind(vpiHandle h)
{
    if (h == NULL)
        return "NULL";
    switch (vpi_get(vpiType, h)) {
    case vpiParameter: return "parameter";
    case vpiTypeParameter: return "type parameter";
    case vpiShortIntTypespec: return "shortint typespec";
    case vpiConstant: return "constant";
    default: return "other type";
    }
}

static void assigns(const char *label, vpiHandle inst, int is_module)
{
    vpiHandle it = inst ? vpi_iterate(vpiParamAssign, inst) : NULL, pa, lhs, rhs;
    struct item list[MAX];
    char full[128];
    int n = 0, i;

    while (it != NULL && (pa = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        lhs = vpi_handle(vpiLhs, pa);
        list[n].name = lhs ? str(vpi_get_str(vpiName, lhs)) : (char *)"NULL";
        list[n++].h = pa;
    }
    qsort(list, n, sizeof list[0], by_name);
    vpi_printf("param assigns of %s: %d\n", label, n);
    for (i = 0; i < n; i++) {
        pa = list[i].h;
        lhs = vpi_handle(vpiLhs, pa);
        rhs = vpi_handle(vpiRhs, pa);
        snprintf(full, sizeof full, "%s.%s", label, list[i].name);
        vpi_printf("  %s: lhs %s, is %s %d; rhs ", list[i].name, kind(lhs), full,
                   same(lhs, find(full)));
        if (rhs != NULL && vpi_get(vpiType, rhs) == vpiShortIntTypespec)
            vpi_printf("shortint typespec");
        else if (rhs != NULL)
            vpi_printf("%d", int_value(rhs));
        else
            vpi_printf("NULL");
        if (is_module)
            vpi_printf("; module is %s %d", label, same(vpi_handle(vpiModule, pa), inst));
        vpi_printf("; scope is %s %d\n", label, same(vpi_handle(vpiScope, pa), inst));
    }
}

static int count(PLI_INT32 rel, vpiHandle ref)
{
    vpiHandle it = ref ? vpi_iterate(rel, ref) : NULL;
    int n = 0;
    while (it != NULL && vpi_scan(it) != NULL)
        n++;
    return n;
}

static PLI_INT32 assigns_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top ? vpi_iterate(vpiDefParam, top) : NULL, dp = NULL, lhs, rhs;
    int n = 0;

    (void)user_data;
    if (top == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    while (it != NULL && (lhs = vpi_scan(it)) != NULL) {
        n++;
        dp = lhs;
    }
    vpi_printf("def params of the top module: %d; of u2: %d\n", n, count(vpiDefParam, find("u2")));
    if (n == 1) {
        lhs = vpi_handle(vpiLhs, dp);
        rhs = vpi_handle(vpiRhs, dp);
        vpi_printf("def param: module is the top module %d, lhs %s, is u2.D %d, rhs %d\n",
                   same(vpi_handle(vpiModule, dp), top), kind(lhs), same(lhs, find("u2.D")),
                   rhs ? int_value(rhs) : -1);
    }
    vpi_printf("u2.D: value %d\n", int_value(find("u2.D")));
    assigns("u1", find("u1"), 1);
    assigns("u2", find("u2"), 1);
    assigns("ifc", find("ifc"), 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_assigns";
    d.calltf = assigns_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
