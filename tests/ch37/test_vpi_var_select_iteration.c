/* VPI application of test_vpi_var_select_iteration (IEEE 1800-2023 37.17, 37.19). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_var_select_iteration"
#define MAX 8

struct item {
    char *name;
    vpiHandle h;
};

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static int selects(vpiHandle array, struct item *list)
{
    vpiHandle it = vpi_iterate(vpiVarSelect, array), h;
    int n = 0;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = copy(vpi_get_str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    return n;
}

static const char *typespec(vpiHandle h)
{
    vpiHandle t = vpi_handle(vpiTypespec, h), l, r;
    static char buf[64];
    if (t == NULL)
        return "NULL";
    switch (vpi_get(vpiType, t)) {
    case vpiIntTypespec:
        return "int typespec";
    case vpiLogicTypespec:
        l = vpi_handle(vpiLeftRange, t);
        r = vpi_handle(vpiRightRange, t);
        if (l == NULL || r == NULL)
            return "logic typespec without range";
        snprintf(buf, sizeof buf, "logic typespec %d:%d", int_value(l), int_value(r));
        return buf;
    default:
        return "other type";
    }
}

static void describe(vpiHandle array, vpiHandle s, int one_dim)
{
    vpiHandle it, x;
    vpi_printf("  %s: full name %s, var select %d, parent is the array %d, size %d, value %d, "
               "typespec %s, ", copy(vpi_get_str(vpiName, s)), copy(vpi_get_str(vpiFullName, s)),
               vpi_get(vpiType, s) == vpiVarSelect ? 1 : 0, same(vpi_handle(vpiParent, s), array),
               (int)vpi_get(vpiSize, s), int_value(s), typespec(s));
    if (one_dim) {
        x = vpi_handle(vpiIndex, s);
        if (x == NULL)
            vpi_printf("index NULL\n");
        else
            vpi_printf("index %d\n", int_value(x));
        return;
    }
    vpi_printf("indices");
    it = vpi_iterate(vpiIndex, s);
    if (it == NULL)
        vpi_printf(" NULL");
    while (it != NULL && (x = vpi_scan(it)) != NULL)
        vpi_printf(" %d", int_value(x));
    vpi_printf("\n");
}

static void put(vpiHandle h, int value)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    v.value.integer = value;
    vpi_put_value(h, &v, NULL, vpiNoDelay);
}

static PLI_INT32 selects_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mem = vpi_handle_by_name((PLI_BYTE8 *)TOP ".mem", NULL);
    vpiHandle m2 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".m2", NULL);
    struct item list[MAX];
    int n, i;

    (void)user_data;
    if (mem == NULL || m2 == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    n = selects(mem, list);
    vpi_printf("var selects of mem: %d\n", n);
    for (i = 0; i < n; i++) {
        describe(mem, list[i].h, 1);
        if (strcmp(list[i].name, "mem[2]") == 0)
            put(list[i].h, 0xa5);
    }
    n = selects(m2, list);
    vpi_printf("var selects of m2: %d:", n);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", list[i].name);
    vpi_printf("\n");
    for (i = 0; i < n; i++)
        if (strcmp(list[i].name, "m2[1][3]") == 0) {
            describe(m2, list[i].h, 0);
            put(list[i].h, 99);
        }
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
