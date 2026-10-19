/* VPI application of test_vpi_systf_override_builtin (IEEE 1800-2023 36.3.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int next_value = 100;

static PLI_INT32 random_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;

    (void)user_data;
    v.format = vpiIntVal;
    v.value.integer = next_value++;
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 stop_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("user $stop called\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)"$random";
    d.calltf = random_calltf;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$stop";
    d.calltf = stop_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
