/* VPI application of test_vpi_active_time_format_null (IEEE 1800-2023 37.82). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "NULL";
}

static PLI_INT32 show_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle args = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = args != NULL ? vpi_scan(args) : NULL;
    vpiHandle active = vpi_handle(vpiActiveTimeFormat, NULL);
    s_vpi_value v;

    (void)user_data;
    v.format = vpiStringVal;
    v.value.str = (PLI_BYTE8 *)"?";
    if (arg != NULL)
        vpi_get_value(arg, &v);
    if (args != NULL)
        vpi_release_handle(args);
    if (active == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: NULL 1\n", v.value.str);
    else
        vpi_printf((PLI_BYTE8 *)"%s: handle 1, tf call %d, name %s\n", v.value.str,
                   vpi_get(vpiType, active) == vpiSysTaskCall, sprop(vpiName, active));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_show";
    d.calltf = show_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
