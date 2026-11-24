#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 observe(p_cb_data data)
{
    vpiHandle own = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_module_lookup_excludes_unit_and_imported_names.actual_member", NULL);
    vpiHandle unit = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_module_lookup_excludes_unit_and_imported_names.unit_only", NULL);
    vpiHandle imported = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_module_lookup_excludes_unit_and_imported_names.imported", NULL);
    (void)data;
    vpi_printf("member=%d unit=%d imported=%d\n", own != NULL, unit != NULL, imported != NULL);
    return 0;
}

static void register_observation(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_observation, NULL};

#ifdef __cplusplus
}
#endif
