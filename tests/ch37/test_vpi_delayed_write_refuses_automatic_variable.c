#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 observe(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle variable, mode, scheduled;
    s_vpi_time delay = {0};
    s_vpi_value value = {0};
    s_vpi_error_info error = {0};
    const char *label;
    int severity;
    (void)user_data;

    if (iterator == NULL)
        return 0;
    variable = vpi_scan(iterator);
    mode = vpi_scan(iterator);
    if (variable == NULL || mode == NULL)
        return 0;
    vpi_release_handle(iterator);

    value.format = vpiIntVal;
    vpi_get_value(mode, &value);
    label = value.value.integer != 0 ? "automatic" : "static";
    value.value.integer = 31;
    delay.type = vpiSimTime;
    delay.low = 2;
    scheduled = vpi_put_value(variable, &value, &delay, vpiTransportDelay | vpiReturnEvent);
    severity = vpi_chk_error(&error);
    vpi_printf("%s scheduled=%d error=%d\n", label, scheduled != NULL, severity >= vpiError);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_delayed_write";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
