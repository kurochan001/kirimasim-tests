/* VPI application of test_vpi_time_callbacks (IEEE 1800-2023 38.36.2, 38.36.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle watched;

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static int value_of_r(void)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(watched, &v);
    return (int)v.value.integer;
}

static PLI_INT32 on_time(p_cb_data cb)
{
    vpi_printf("%d: %s, r = %d\n", now(), cb->user_data, value_of_r());
    return 0;
}

static PLI_INT32 on_end(p_cb_data cb)
{
    (void)cb;
    vpi_printf("%d: end of simulation\n", now());
    return 0;
}

static void at_delay(PLI_INT32 reason, PLI_INT32 (*rtn)(p_cb_data), const char *what, int delay)
{
    static s_vpi_time t;
    s_cb_data cb;
    memset(&cb, 0, sizeof cb);
    t.type = vpiSimTime;
    t.high = 0;
    t.low = delay;
    cb.reason = reason;
    cb.cb_rtn = rtn;
    cb.time = &t;
    cb.user_data = (PLI_BYTE8 *)what;
    vpi_register_cb(&cb);
}

static PLI_INT32 schedule_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    s_cb_data cb;

    (void)user_data;
    watched = vpi_scan(it);
    vpi_free_object(it);
    at_delay(cbAfterDelay, on_time, "after delay", 10);
    at_delay(cbReadOnlySynch, on_time, "read-only synch", 10);
    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfSimulation;
    cb.cb_rtn = on_end;
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
{
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.sysfunctype = 0;
        d.tfname = (PLI_BYTE8 *)"$vt_schedule";
        d.calltf = schedule_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
