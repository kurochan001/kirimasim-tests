#include <stddef.h>
#define VPI_COMPATIBILITY_VERSION_1364v2001 1
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    PLI_INT32 mode = vpi_get(vpiCompatibilityMode, NULL);
    vpiHandle module = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_compatibility_mode_uses_null_handle_for_bound_mode", NULL);
    vpi_printf("compatibility 1364-2001=%d regular module type=%d\n",
               mode == vpiMode1364v2001,
               module != NULL && vpi_get(vpiType, module) == vpiModule);
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = "$vt_compat_property";
    definition.calltf = inspect;
    vpi_register_systf(&definition);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
