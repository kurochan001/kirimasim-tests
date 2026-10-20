/* VPI application of test_vpi_get_systf_info (IEEE 1800-2023 38.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle twice_handle;
static char info_data[] = "info data";
static char twice_data[] = "twice data";

static PLI_INT32 twice_calltf(PLI_BYTE8 *user_data);

static PLI_INT32 info_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_systf_data d;
    vpiHandle systf = vpi_handle(vpiUserSystf, vpi_handle(vpiSysTfCall, NULL));

    memset(&d, 0, sizeof d);
    if (systf != NULL)
        vpi_get_systf_info(systf, &d);
    vpi_printf("from the call: %s, %s, user data \"%s\", same as passed: %s, calltf: %s\n",
               d.tfname ? d.tfname : "(no name)", d.type == vpiSysTask ? "task" : "other",
               d.user_data ? d.user_data : "", d.user_data == user_data ? "yes" : "no",
               d.calltf == info_calltf ? "this routine" : "another");
    memset(&d, 0, sizeof d);
    if (twice_handle != NULL)
        vpi_get_systf_info(twice_handle, &d);
    vpi_printf("from the registration: %s, %s, %s, user data \"%s\", calltf: %s\n",
               d.tfname ? d.tfname : "(no name)", d.type == vpiSysFunc ? "function" : "other",
               d.sysfunctype == vpiIntFunc ? "vpiIntFunc" : "other type",
               d.user_data ? d.user_data : "",
               d.calltf == twice_calltf ? "its routine" : "another");
    return 0;
}

static PLI_INT32 twice_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    (void)user_data;
    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    v.value.integer *= 2;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_info";
    d.calltf = info_calltf;
    d.user_data = info_data;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)"$vt_twice";
    d.calltf = twice_calltf;
    d.user_data = twice_data;
    twice_handle = vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
