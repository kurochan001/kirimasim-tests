#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 test_targets(PLI_BYTE8 *mode)
{
    int release = mode[0] == 'r';
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    int errors[3] = {-1, -1, -1};
    for (int i = 0; iterator != NULL && i < 3; ++i) {
        vpiHandle target = vpi_scan(iterator);
        if (target == NULL) {
            iterator = NULL;
            break;
        }
        s_vpi_value value = {0};
        value.format = vpiIntVal;
        value.value.integer = 3;
        vpi_put_value(target, &value, NULL, release ? vpiReleaseFlag : vpiForceFlag);
        errors[i] = vpi_chk_error(NULL) >= vpiError;
    }
    if (iterator != NULL) vpi_release_handle(iterator);
    vpi_printf("%s errors=%d %d %d\n", release ? "release" : "force", errors[0], errors[1], errors[2]);
    return 0;
}

static void register_task(const char *name, const char *mode)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)name;
    task.user_data = (PLI_BYTE8 *)mode;
    task.calltf = test_targets;
    vpi_register_systf(&task);
}

static void register_tests(void)
{
    register_task("$vt_force_selects", "force");
    register_task("$vt_release_selects", "release");
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};

#ifdef __cplusplus
}
#endif
