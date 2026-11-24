#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 observe(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call != NULL ? vpi_handle(vpiScope, call) : NULL;
    vpiHandle packet = scope != NULL ? vpi_handle_by_name((PLI_BYTE8 *)"packet", scope) : NULL;
    vpiHandle reading = scope != NULL ? vpi_handle_by_name((PLI_BYTE8 *)"packet.reading", scope) : NULL;
    s_vpi_value value = {0};
    s_vpi_error_info error = {0};
    int reading_value, whole_read_error, whole_write_error, member_write_error;
    (void)user_data;

    if (packet == NULL || reading == NULL) {
        vpi_printf("aggregate or member not found\n");
        return 0;
    }

    value.format = vpiIntVal;
    vpi_get_value(reading, &value);
    reading_value = (int)value.value.integer;
    value.value.integer = 31;
    vpi_put_value(reading, &value, NULL, vpiNoDelay);
    member_write_error = vpi_chk_error(&error) >= vpiError;

    vpi_get_value(packet, &value);
    whole_read_error = vpi_chk_error(&error) >= vpiError;
    value.format = vpiIntVal;
    value.value.integer = 99;
    vpi_put_value(packet, &value, NULL, vpiNoDelay);
    whole_write_error = vpi_chk_error(&error) >= vpiError;

    vpi_printf("member read=%d whole read error=%d whole write error=%d member write error=%d\n",
               reading_value, whole_read_error, whole_write_error, member_write_error);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_access";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
