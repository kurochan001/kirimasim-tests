/* VPI application of test_vpi_parameters (IEEE 1800-2023 37.28). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 8

struct named {
    char name[16];
    vpiHandle h;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct named *)a)->name, ((const struct named *)b)->name);
}

static int collect(vpiHandle it, PLI_INT32 name_of, struct named *list)
{
    vpiHandle h;
    int n = 0;
    while (it && (h = vpi_scan(it)) != NULL) {
        vpiHandle named = name_of ? vpi_handle(name_of, h) : h;
        PLI_BYTE8 *s = named ? vpi_get_str(vpiName, named) : NULL;
        if (n == MAX)
            continue;
        snprintf(list[n].name, sizeof list[n].name, "%s", s ? s : "(null)");
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    return n;
}

static void print_value(vpiHandle h)
{
    s_vpi_value v;
    if (vpi_get(vpiConstType, h) == vpiRealConst) {
        v.format = vpiRealVal;
        vpi_get_value(h, &v);
        vpi_printf("%.2f", v.value.real);
    } else {
        v.format = vpiIntVal;
        vpi_get_value(h, &v);
        vpi_printf("%d", (int)v.value.integer);
    }
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 parameters_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle u = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_parameters.u", NULL);
    struct named list[MAX];
    int n, i;

    (void)user_data;
    if (u == NULL) {
        vpi_printf("u not found\n");
        return 0;
    }
    n = collect(vpi_iterate(vpiParameter, u), 0, list);
    for (i = 0; i < n; i++) {
        vpiHandle h = list[i].h;
        vpiHandle left = vpi_handle(vpiLeftRange, h), right = vpi_handle(vpiRightRange, h);
        vpiHandle expr = vpi_handle(vpiExpr, h);
        vpi_printf("%s: value ", list[i].name);
        print_value(h);
        vpi_printf(", local %d", (int)vpi_get(vpiLocalParam, h));
        if (left && right)
            vpi_printf(", range %d:%d", int_value(left), int_value(right));
        else
            vpi_printf(", no range");
        if (strcmp(list[i].name, "W") == 0 || strcmp(list[i].name, "P") == 0)
            vpi_printf(", default %d", expr ? int_value(expr) : -1);
        vpi_printf("\n");
    }
    n = collect(vpi_iterate(vpiParamAssign, u), vpiLhs, list);
    for (i = 0; i < n; i++) {
        vpiHandle rhs = vpi_handle(vpiRhs, list[i].h);
        vpi_printf("parameter assignment: %s = %d\n", list[i].name, rhs ? int_value(rhs) : -1);
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_parameters";
    d.calltf = parameters_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
