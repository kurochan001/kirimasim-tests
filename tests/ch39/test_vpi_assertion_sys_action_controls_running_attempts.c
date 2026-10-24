/* VPI application of test_vpi_assertion_sys_action_controls_running_attempts (IEEE 1800-2023 39.5.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

struct pair {
    const char *name;
    PLI_INT32 code;
};

static const struct pair controls[] = {
    {"disable pass action", vpiAssertionSysDisablePassAction},
    {"enable pass action", vpiAssertionSysEnablePassAction},
    {"disable fail action", vpiAssertionSysDisableFailAction},
    {"enable fail action", vpiAssertionSysEnableFailAction},
};

#define COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

static PLI_INT32 system_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;
    int i;

    (void)user_data;
    if (arg == NULL) {
        vpi_printf((PLI_BYTE8 *)"$vt_system: no argument\n");
        return 0;
    }
    vpi_release_handle(it);
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    for (i = 0; i < COUNT(controls); i++)
        if (strcmp(v.value.str, controls[i].name) == 0) {
            vpi_control(controls[i].code, (vpiHandle)NULL);
            return 0;
        }
    vpi_printf((PLI_BYTE8 *)"$vt_system: unknown control %s\n", v.value.str);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_system";
    d.calltf = system_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
