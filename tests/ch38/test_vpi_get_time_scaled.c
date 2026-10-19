/* VPI application of test_vpi_get_time_scaled (IEEE 1800-2023 38.13). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 now_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle mod;
    s_vpi_time t;

    (void)user_data;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    vpi_printf("simulation time: %u\n", (unsigned)t.low);
    while ((mod = vpi_scan(it)) != NULL) {
        t.type = vpiScaledRealTime;
        vpi_get_time(mod, &t);
        vpi_printf("%s: unit %d, precision %d, time %.3f\n", vpi_get_str(vpiFullName, mod),
                   (int)vpi_get(vpiTimeUnit, mod), (int)vpi_get(vpiTimePrecision, mod), t.real);
    }
    return 0;
}

static void register_all(void)
{
{
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.sysfunctype = 0;
        d.tfname = (PLI_BYTE8 *)"$vt_now";
        d.calltf = now_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
