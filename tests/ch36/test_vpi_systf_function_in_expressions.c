/* VPI application of test_vpi_systf_function_in_expressions (IEEE 1800-2023 36.5, 13.4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 twice_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle arg = it != NULL ? vpi_scan(it) : NULL;
    s_vpi_value v;

    (void)user_data;
    if (it != NULL && arg != NULL)
        vpi_free_object(it);
    v.format = vpiIntVal;
    v.value.integer = 0;
    if (arg != NULL)
        vpi_get_value(arg, &v);
    v.value.integer *= 2;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)"$vt_twice";
    d.calltf = twice_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
