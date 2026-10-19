/* VPI application of test_vpi_control_finish (IEEE 1800-2023 38.4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    (void)cb;
    vpi_control(vpiFinish, 0);
    return 0;
}

static PLI_INT32 on_end(p_cb_data cb)
{
    (void)cb;
    vpi_printf("%d: end of simulation\n", now());
    return 0;
}

static PLI_INT32 finish_calltf(PLI_BYTE8 *user_data)
{
    static s_vpi_time t;
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    s_vpi_value v;
    s_cb_data cb;

    (void)user_data;
    v.format = vpiIntVal;
    vpi_get_value(vpi_scan(it), &v);
    vpi_free_object(it);
    memset(&cb, 0, sizeof cb);
    t.type = vpiSimTime;
    t.high = 0;
    t.low = v.value.integer;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &t;
    vpi_register_cb(&cb);
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
        d.tfname = (PLI_BYTE8 *)"$vt_finish_after";
        d.calltf = finish_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
