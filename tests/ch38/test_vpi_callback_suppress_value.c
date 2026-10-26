/* VPI application of test_vpi_callback_suppress_value (IEEE 1800-2023 38.36.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_callback_suppress_value"

static int value_calls;
static int no_value = 1, time_ok = 1;

static PLI_INT32 on_value(p_cb_data cb)
{
    value_calls++;
    if (cb->value != NULL && cb->value->format != vpiSuppressVal)
        no_value = 0;
    if (cb->time != NULL && cb->time->type != vpiSuppressTime)
        time_ok = 0;
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle v = vpi_handle_by_name((PLI_BYTE8 *)TOP ".v", NULL);
    static s_vpi_time when;
    static s_vpi_value value;
    s_cb_data cb;

    (void)user_data;
    if (v == NULL) {
        vpi_printf("v not found\n");
        return 0;
    }
    memset(&cb, 0, sizeof cb);
    memset(&when, 0, sizeof when);
    memset(&value, 0, sizeof value);
    when.type = vpiSuppressTime;
    value.format = vpiSuppressVal;
    cb.reason = cbValueChange;
    cb.cb_rtn = on_value;
    cb.obj = v;
    cb.time = &when;
    cb.value = &value;
    vpi_register_cb(&cb);
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("cbValueChange with vpiSuppressVal: calls %d, no value %d, "
               "time suppressed %d\n", value_calls, no_value, time_ok);
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_watch", watch_calltf);
    add("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
