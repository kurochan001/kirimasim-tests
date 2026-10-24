/* VPI application of test_vpi_value_parameter_props (IEEE 1800-2023 37.28). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_value_parameter_props"
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

static int params(vpiHandle scope, struct item *list)
{
    vpiHandle it = scope ? vpi_iterate(vpiParameter, scope) : NULL, h;
    int n = 0;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = str(vpi_get_str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    return n;
}

static void describe(vpiHandle p, const char *name, vpiHandle u, vpiHandle scope,
                     const char *scope_name)
{
    vpi_printf("%s: full name %s, value %d, module is u %d, scope is %s %d", name,
               str(vpi_get_str(vpiFullName, p)), int_value(p), same(vpi_handle(vpiModule, p), u),
               scope_name, same(vpi_handle(vpiScope, p), scope));
    if (strcmp(name, "U") != 0 && strcmp(name, "GL") != 0)
        vpi_printf(", signed %d, size %d", (int)vpi_get(vpiSigned, p), (int)vpi_get(vpiSize, p));
    vpi_printf("\n");
}

static PLI_INT32 params_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle u = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);
    vpiHandle g = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u.g", NULL);
    struct item list[MAX];
    int n, i;

    (void)user_data;
    if (u == NULL || g == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    n = params(u, list);
    vpi_printf("parameters of u (%d):", n);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", list[i].name);
    vpi_printf("\n");
    for (i = 0; i < n; i++)
        describe(list[i].h, list[i].name, u, u, "u");
    n = params(g, list);
    vpi_printf("parameters of u.g (%d):", n);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", list[i].name);
    vpi_printf("\n");
    for (i = 0; i < n; i++)
        describe(list[i].h, list[i].name, u, g, "g");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_params";
    d.calltf = params_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
