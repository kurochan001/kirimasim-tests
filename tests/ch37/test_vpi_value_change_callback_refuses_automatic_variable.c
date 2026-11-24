#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 on_change(p_cb_data data)
{
    const char *label = (const char *)data->user_data;
    if (data->value != NULL)
        vpi_printf("%s callback value=%d\n", label, (int)data->value->value.integer);
    return 0;
}

static PLI_INT32 observe(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle variable, mode, registered;
    s_vpi_time time = {0};
    s_vpi_value value = {0};
    s_vpi_error_info error = {0};
    s_cb_data callback = {0};
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

    time.type = vpiSuppressTime;
    value.value.integer = 0;
    callback.reason = cbValueChange;
    callback.obj = variable;
    callback.time = &time;
    callback.value = &value;
    callback.cb_rtn = on_change;
    callback.user_data = (PLI_BYTE8 *)label;
    registered = vpi_register_cb(&callback);
    severity = vpi_chk_error(&error);
    vpi_printf("%s registered=%d error=%d\n", label, registered != NULL, severity >= vpiError);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_watch_value";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
