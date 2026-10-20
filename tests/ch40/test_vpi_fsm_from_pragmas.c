/* VPI application of test_vpi_fsm_from_pragmas (IEEE 1800-2023 40.5.2, 40.4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 16

static int by_value(const void *pa, const void *pb)
{
    return *(const int *)pa - *(const int *)pb;
}

static PLI_INT32 fsm_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top, it, fsm = NULL, h, expr;
    int n_fsms = 0, values[MAX], n_values = 0, ones = 1, i;
    s_vpi_value v;

    (void)user_data;
    top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_fsm_from_pragmas", NULL);
    it = top ? vpi_iterate(vpiFsm, top) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        n_fsms++;
        fsm = h;
    }
    vpi_printf("FSMs in the instance: %d\n", n_fsms);
    if (n_fsms != 1)
        return 0;
    expr = vpi_handle(vpiFsmStateExpression, fsm);
    vpi_printf("state expression: %s\n", expr ? vpi_get_str(vpiName, expr) : "none");
    it = vpi_iterate(vpiFsmStates, fsm);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n_values == MAX)
            continue;
        v.format = vpiIntVal;
        vpi_get_value(h, &v);
        values[n_values++] = v.value.integer;
        if (vpi_get(vpiCoveredMax, h) != 1)
            ones = 0;
    }
    qsort(values, n_values, sizeof values[0], by_value);
    vpi_printf("states:");
    for (i = 0; i < n_values; i++)
        vpi_printf(" %d", values[i]);
    vpi_printf("\n");
    vpi_printf("coverable items of the FSM: %d\n", (int)vpi_get(vpiCoveredMax, fsm));
    vpi_printf("coverable items of each state: %s\n", ones ? "1" : "not 1");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_fsm";
    d.calltf = fsm_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
