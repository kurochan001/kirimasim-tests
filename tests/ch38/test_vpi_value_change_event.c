/* VPI application of test_vpi_value_change_event (IEEE 1800-2023 38.36.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 on_trigger(p_cb_data cb)
{
    vpi_printf("%d: %s triggered, %s\n", (int)cb->time->low, vpi_get_str(vpiFullName, cb->obj),
               cb->value == NULL ? "no value" : "with a value");
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    static s_vpi_time t;
    static s_vpi_value v;
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    s_cb_data cb;

    (void)user_data;
    t.type = vpiSimTime;
    v.format = vpiBinStrVal;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbValueChange;
    cb.cb_rtn = on_trigger;
    cb.obj = vpi_scan(it);
    cb.time = &t;
    cb.value = &v;
    vpi_free_object(it);
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    {
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.tfname = (PLI_BYTE8 *)"$vt_watch";
        d.calltf = watch_calltf;
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
