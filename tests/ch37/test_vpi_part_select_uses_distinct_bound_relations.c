#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int int_value(vpiHandle handle)
{
    s_vpi_value value = {0};
    if (handle == NULL)
        return -1;
    value.format = vpiIntVal;
    vpi_get_value(handle, &value);
    return (int)value.value.integer;
}

static PLI_INT32 observe(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle part = args != NULL ? vpi_scan(args) : NULL;
    vpiHandle ambiguous;
    s_vpi_error_info error = {0};
    int left, right, severity;
    (void)user_data;

    if (part == NULL || vpi_get(vpiType, part) != vpiPartSelect) {
        vpi_printf("missing part-select argument\n");
        return 0;
    }
    left = int_value(vpi_handle(vpiLeftRange, part));
    right = int_value(vpi_handle(vpiRightRange, part));
    ambiguous = vpi_handle(vpiExpr, part);
    severity = vpi_chk_error(&error);
    vpi_printf("left=%d right=%d ambiguous=%d error=%d\n",
              left, right, ambiguous != NULL, severity >= vpiError);
    if (args != NULL)
        vpi_release_handle(args);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_bounds";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
