#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 put_target(PLI_BYTE8 *mode)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle arguments = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle target = arguments != NULL ? vpi_scan(arguments) : NULL;
    if (target == NULL) {
        vpi_printf("missing force or release target\n");
        return 0;
    }
    vpi_release_handle(arguments);

    int release = mode[0] == 'r';
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    value.value.integer = release ? -1 : 0x6a5;
    vpi_put_value(target, &value, NULL, release ? vpiReleaseFlag : vpiForceFlag);
    if (release) vpi_printf("release readback=%03x\n", (unsigned)value.value.integer);
    return 0;
}

static void register_task(const char *name, const char *mode)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)name;
    task.user_data = (PLI_BYTE8 *)mode;
    task.calltf = put_target;
    vpi_register_systf(&task);
}

static void register_tests(void)
{
    register_task("$vt_force_target", "force");
    register_task("$vt_release_target", "release");
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};

#ifdef __cplusplus
}
#endif
