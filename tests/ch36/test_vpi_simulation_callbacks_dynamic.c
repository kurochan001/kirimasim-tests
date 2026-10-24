/* VPI application of test_vpi_simulation_callbacks_dynamic (IEEE 1800-2023 36.9.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char change_data[] = "change", delay_data[] = "delay", end_data[] = "end";

static unsigned now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (unsigned)t.low;
}

static const char *reason_name(PLI_INT32 reason)
{
    switch (reason) {
    case cbValueChange: return "cbValueChange";
    case cbAfterDelay: return "cbAfterDelay";
    case cbEndOfSimulation: return "cbEndOfSimulation";
    default: return "other";
    }
}

static PLI_INT32 on_callback(p_cb_data cb)
{
    vpi_printf((PLI_BYTE8 *)"%u: %s, user data %s", now(), reason_name(cb->reason),
               cb->user_data != NULL ? cb->user_data : "(null)");
    if (cb->reason == cbValueChange && cb->value != NULL)
        vpi_printf((PLI_BYTE8 *)", x = %d", (int)cb->value->value.integer);
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

/* The time and value structures stay valid for the whole simulation. */
static s_vpi_time change_time, delay_time;
static s_vpi_value change_value;

static PLI_INT32 start_of_simulation(p_cb_data start)
{
    s_cb_data cb;

    (void)start;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbValueChange;
    cb.cb_rtn = on_callback;
    cb.obj = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_simulation_callbacks_dynamic.x", NULL);
    change_time.type = vpiSimTime;
    cb.time = &change_time;
    change_value.format = vpiIntVal;
    cb.value = &change_value;
    cb.user_data = change_data;
    vpi_register_cb(&cb);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_callback;
    delay_time.type = vpiSimTime;
    delay_time.high = 0;
    delay_time.low = 5;
    cb.time = &delay_time;
    cb.user_data = delay_data;
    vpi_register_cb(&cb);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfSimulation;
    cb.cb_rtn = on_callback;
    cb.user_data = end_data;
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
