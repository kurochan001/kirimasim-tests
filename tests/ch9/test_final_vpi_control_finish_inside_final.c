/* VPI application of test_final_vpi_control_finish_inside_final
   (IEEE 1800-2023 9.2.3, 38.4): $vt_finish calls vpi_control(vpiFinish, 0). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 finish_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_control(vpiFinish, 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.sysfunctype = 0;
    d.tfname = (PLI_BYTE8 *)"$vt_finish";
    d.calltf = finish_calltf;
    d.compiletf = 0;
    d.sizetf = 0;
    d.user_data = (PLI_BYTE8 *)0;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
