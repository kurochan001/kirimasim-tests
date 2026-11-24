#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int by_external_name(vpiHandle module, const char *name)
{
    vpiHandle variable = vpi_handle_by_name((PLI_BYTE8 *)name, module);
    s_vpi_value value = {0};
    if (variable == NULL)
        return -1;
    value.format = vpiIntVal;
    vpi_get_value(variable, &value);
    return value.value.integer;
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call == NULL ? NULL : vpi_handle(vpiScope, call);
    (void)unused;
    if (scope != NULL)
        vpi_printf("external loop values=%d/%d\n",
                   by_external_name(scope, "genblk1[0].marker"),
                   by_external_name(scope, "genblk1[1].marker"));
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_inspect_unnamed";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
