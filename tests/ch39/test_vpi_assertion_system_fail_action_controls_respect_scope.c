#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_system_fail_action_controls_respect_scope"

static PLI_INT32 record_change(p_cb_data cb)
{
    s_vpi_time when = {0};
    when.type = vpiSimTime;
    vpi_get_time(NULL, &when);
    const char *action = cb->user_data == NULL ? "missing client data" : cb->user_data;
    vpi_printf("%u system action %s\n", (unsigned)when.low, action);
    return 0;
}

static void watch(PLI_INT32 reason, const char *action)
{
    s_cb_data cb = {0};
    cb.reason = reason;
    cb.cb_rtn = record_change;
    cb.user_data = (PLI_BYTE8 *)action;
    if (!vpi_register_cb(&cb))
        vpi_printf("unable to register system action %s\n", action);
}

static int monitoring;

static PLI_INT32 control_failures(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle argument = it != NULL ? vpi_scan(it) : NULL;
    if (!argument)
        return 0;
    s_vpi_value selection = {0};
    selection.format = vpiIntVal;
    vpi_get_value(argument, &selection);
    vpi_release_handle(it);
    int phase = selection.value.integer;

    if (!monitoring) {
        monitoring = 1;
        watch(cbAssertionSysDisableFailAction, "disabled");
        watch(cbAssertionSysEnableFailAction, "enabled");
    }
    vpiHandle scope = NULL;
    if (phase < 2) {
        scope = vpi_handle_by_name((PLI_BYTE8 *)TOP ".left", NULL);
        if (scope == NULL) {
            vpi_printf("scope .left missing\n");
            return 0;
        }
    }
    PLI_INT32 operation = (phase & 1) ? vpiAssertionSysEnableFailAction
                                     : vpiAssertionSysDisableFailAction;
    vpi_control(operation, scope);
    return 0;
}

static void register_setup(void)
{
    s_vpi_systf_data def = {0};
    def.type = vpiSysTask;
    def.tfname = (PLI_BYTE8 *)"$vt_fail_action_control";
    def.calltf = control_failures;
    vpi_register_systf(&def);
}

void (*vlog_startup_routines[])(void) = {register_setup, NULL};

#ifdef __cplusplus
}
#endif
