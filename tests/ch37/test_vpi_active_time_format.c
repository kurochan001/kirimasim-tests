/* VPI application of test_vpi_active_time_format (IEEE 1800-2023 37.82). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 format_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiActiveTimeFormat, NULL), it, arg;
    s_vpi_value v;

    (void)user_data;
    if (call == NULL) {
        vpi_printf((PLI_BYTE8 *)"active time format: NULL\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"active time format: system task call %d, %s, arguments:",
               vpi_get(vpiType, call) == vpiSysTaskCall, vpi_get_str(vpiName, call));
    it = vpi_iterate(vpiArgument, call);
    if (it != NULL)
        while ((arg = vpi_scan(it)) != NULL) {
            if (vpi_get(vpiConstType, arg) == vpiStringConst) {
                v.format = vpiStringVal;
                vpi_get_value(arg, &v);
                vpi_printf((PLI_BYTE8 *)" \"%s\"", v.value.str);
            } else {
                v.format = vpiIntVal;
                vpi_get_value(arg, &v);
                vpi_printf((PLI_BYTE8 *)" %d", (int)v.value.integer);
            }
        }
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_format";
    d.calltf = format_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
