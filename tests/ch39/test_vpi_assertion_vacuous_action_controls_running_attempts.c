/* VPI application of test_vpi_assertion_vacuous_action_controls_running_attempts (IEEE 1800-2023 39.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_vacuous_action_controls_running_attempts"

struct pair {
    const char *name;
    PLI_INT32 code;
};

static const struct pair controls[] = {
    {"disable pass action", vpiAssertionDisablePassAction},
    {"enable pass action", vpiAssertionEnablePassAction},
    {"disable vacuous action", vpiAssertionDisableVacuousAction},
    {"enable nonvacuous action", vpiAssertionEnableNonvacuousAction},
};

#define COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

/* Copies the string value of the next argument into buf. */
static int next_string(vpiHandle it, char *buf, size_t size)
{
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    if (arg == NULL)
        return 0;
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    snprintf(buf, size, "%s", v.value.str);
    return 1;
}

static PLI_INT32 control_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    char name[32], op[32], full[128];
    vpiHandle assertion;
    int ok, i;

    (void)user_data;
    ok = next_string(it, name, sizeof name) && next_string(it, op, sizeof op);
    if (it && ok)
        vpi_release_handle(it);
    if (!ok) {
        vpi_printf((PLI_BYTE8 *)"$vt_control: two arguments needed\n");
        return 0;
    }
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    assertion = vpi_handle_by_name(full, NULL);
    if (assertion == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s not found\n", full);
        return 0;
    }
    for (i = 0; i < COUNT(controls); i++)
        if (strcmp(op, controls[i].name) == 0) {
            vpi_control(controls[i].code, assertion);
            return 0;
        }
    vpi_printf((PLI_BYTE8 *)"$vt_control: unknown control %s\n", op);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_control";
    d.calltf = control_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
