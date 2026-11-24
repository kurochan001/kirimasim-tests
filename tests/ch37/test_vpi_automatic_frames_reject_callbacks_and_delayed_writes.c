#include <stddef.h>
#include <stdio.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 callback(p_cb_data data)
{
    (void)data;
    vpi_printf("unexpected callback");
    return 0;
}

static int report_error(const char *operation)
{
    s_vpi_error_info info = {0};
    if (vpi_chk_error(&info) < vpiError)
        return 0;
    if (info.message != NULL)
        fprintf(stderr, "%s error: %s\n", operation, (const char *)info.message);
    return 1;
}

static PLI_INT32 check_variable(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle automatic_var, static_var, id, registered, scheduled;
    s_vpi_time callback_time = {0}, write_time = {0};
    s_vpi_value value = {0};
    s_cb_data request = {0};
    int frame, callback_error, delay_error;
    (void)user_data;

    if (iterator == NULL)
        return 0;
    automatic_var = vpi_scan(iterator);
    static_var = vpi_scan(iterator);
    id = vpi_scan(iterator);
    if (automatic_var == NULL || static_var == NULL || id == NULL)
        return 0;
    vpi_release_handle(iterator);

    value.format = vpiIntVal;
    vpi_get_value(id, &value);
    frame = (int)value.value.integer;

    callback_time.type = vpiSuppressTime;
    request.reason = cbValueChange;
    request.cb_rtn = callback;
    request.obj = static_var;
    request.time = &callback_time;
    registered = vpi_register_cb(&request);
    vpi_printf("frame %d static callback=%d\n", frame, registered != NULL);
    if (registered != NULL)
        vpi_remove_cb(registered);

    request.obj = automatic_var;
    registered = vpi_register_cb(&request);
    callback_error = report_error("callback");
    vpi_printf("frame %d automatic callback=%d error=%d\n",
               frame, registered != NULL, callback_error);

    write_time.type = vpiSimTime;
    write_time.low = 2;
    value.value.integer = 900 + frame;
    scheduled = vpi_put_value(automatic_var, &value, &write_time,
                              vpiPureTransportDelay | vpiReturnEvent);
    delay_error = report_error("delay");
    vpi_printf("frame %d scheduled=%d error=%d\n", frame, scheduled != NULL, delay_error);

    value.value.integer = 60 + frame;
    vpi_put_value(automatic_var, &value, NULL, vpiNoDelay);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_auto";
    task.calltf = check_variable;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
