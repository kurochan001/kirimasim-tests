/* VPI application of test_vpi_systf_registration_fields (IEEE 1800-2023 36.9.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char task_data[] = "task data";
static PLI_INT32 function_data = 41;
static int started, compiletf_calls, compiletf_early, compiletf_with_data;

static PLI_INT32 mark_compiletf(PLI_BYTE8 *user_data)
{
    compiletf_calls++;
    if (!started)
        compiletf_early++;
    if (user_data == task_data)
        compiletf_with_data++;
    return 0;
}

static PLI_INT32 mark_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_time t;

    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    vpi_printf((PLI_BYTE8 *)"$vt_mark at %u: user data \"%s\"\n", (unsigned)t.low,
               user_data != NULL ? user_data : "(null)");
    return 0;
}

static PLI_INT32 val_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;

    v.format = vpiIntVal;
    v.value.integer = user_data != NULL ? *(PLI_INT32 *)user_data + 1 : -1;
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"compiletf of $vt_mark: %d calls, %d before the start of "
               "simulation, %d with the user data\n", compiletf_calls, compiletf_early,
               compiletf_with_data);
    return 0;
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    started = 1;
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    s_cb_data cb;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_mark";
    d.compiletf = mark_compiletf;
    d.calltf = mark_calltf;
    d.user_data = task_data;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)"$vt_val";
    d.calltf = val_calltf;
    d.user_data = (PLI_BYTE8 *)&function_data;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_report";
    d.calltf = report_calltf;
    vpi_register_systf(&d);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
