#include <stdio.h>
#include "svdpi.h"
#include "vpi_user.h"

extern int call_dpi_from_system_task(void);
static int call_cookie = 37;

int probe_system_task_access(void)
{
    const vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    const int error = vpi_chk_error(NULL) != 0;
    return (call != NULL) | (error << 1);
}

static PLI_INT32 compile_call(PLI_BYTE8 *data)
{
    (void)data;
    printf("compile call=%d\n", vpi_handle(vpiSysTfCall, NULL) != NULL);
    return 0;
}

static PLI_INT32 run_call(PLI_BYTE8 *data)
{
    (void)data;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    if (call == NULL) {
        puts("system task call missing");
        return 0;
    }
    const int stored = vpi_put_userdata(call, &call_cookie) && vpi_get_userdata(call) == &call_cookie;
    printf("system task userdata=%d\n", stored);

    vpiHandle args = vpi_iterate(vpiArgument, call);
    vpiHandle arg = args ? vpi_scan(args) : NULL;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    if (arg) {
        vpi_get_value(arg, &value);
        vpi_release_handle(args);
    }
    if (value.value.integer) {
        const svScope next = svGetScopeFromName("test_dpi_does_not_inherit_outer_vpi_system_task");
        if (next == NULL) {
            puts("callback cannot find export scope");
            return 0;
        }
        svSetScope(next);
        const int result = call_dpi_from_system_task();
        printf("nested DPI call=%d error=%d\n", result & 1, result >> 1);
    }
    const vpiHandle resumed = vpi_handle(vpiSysTfCall, NULL);
    printf("system task resumed=%d userdata=%d\n", resumed != NULL,
           resumed != NULL && vpi_get_userdata(resumed) == &call_cookie);
    return 0;
}

static void register_boundary_task(void)
{
    s_vpi_systf_data info = {0};
    info.type = vpiSysTask;
    info.tfname = (PLI_BYTE8 *)"$check_vpi_task_boundary";
    info.calltf = run_call;
    info.compiletf = compile_call;
    vpi_register_systf(&info);
}

void (*vlog_startup_routines[])(void) = {register_boundary_task, NULL};
