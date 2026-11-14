/* VPI application of test_vpi_force_release_net_part_select (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle first_argument(void)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = call ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle arg = args ? vpi_scan(args) : NULL;

    if (arg != NULL)
        vpi_release_handle(args);
    return arg;
}

static PLI_INT32 put_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle arg = first_argument();
    s_vpi_value value;
    PLI_INT32 flags = user_data[0] == 'f' ? vpiForceFlag : vpiReleaseFlag;

    if (arg == NULL) {
        vpi_printf((PLI_BYTE8 *)"no argument\n");
        return 0;
    }
    value.format = vpiIntVal;
    value.value.integer = 5;
    vpi_put_value(arg, &value, NULL, flags);
    return 0;
}

static void register_task(const char *name, const char *data)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = put_calltf;
    d.user_data = (PLI_BYTE8 *)data;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    register_task("$vt_force", "f");
    register_task("$vt_release", "r");
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
