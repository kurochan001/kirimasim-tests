/* VPI application of test_vpi_put_value_delay_modes (IEEE 1800-2023 38.34). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 put_calltf(PLI_BYTE8 *user_data)
{
    static const PLI_INT32 modes[] = {
        vpiNoDelay, vpiInertialDelay, vpiTransportDelay, vpiPureTransportDelay
    };
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle obj = vpi_scan(it);
    s_vpi_value v, value, delay, mode;
    s_vpi_time t;

    (void)user_data;
    value.format = delay.format = mode.format = vpiIntVal;
    vpi_get_value(vpi_scan(it), &value);
    vpi_get_value(vpi_scan(it), &delay);
    vpi_get_value(vpi_scan(it), &mode);
    vpi_free_object(it);
    v.format = vpiIntVal;
    v.value.integer = value.value.integer;
    t.type = vpiScaledRealTime;
    t.high = t.low = 0;
    t.real = delay.value.integer;
    vpi_put_value(obj, &v, &t, modes[mode.value.integer]);
    return 0;
}

static void register_all(void)
{
{
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.sysfunctype = 0;
        d.tfname = (PLI_BYTE8 *)"$vt_put";
        d.calltf = put_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
