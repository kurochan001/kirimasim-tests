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
    vpiHandle target = iterator != NULL ? vpi_scan(iterator) : NULL;
    s_vpi_value value = {0};
    s_vpi_error_info error = {0};
    (void)user_data;

    if (target == NULL) {
        vpi_printf("select handle not found\n");
        return 0;
    }
    value.format = vpiScalarVal;
    value.value.scalar = vpi1;
    vpi_put_value(target, &value, NULL, vpiNoDelay);
    vpi_printf("put error=%d\n", vpi_chk_error(&error) >= vpiError);
    vpi_release_handle(iterator);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_put_bit";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
