#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle find_package(void)
{
    vpiHandle iterator = vpi_iterate(vpiPackage, NULL);
    vpiHandle package;
    if (iterator == NULL)
        return NULL;
    while ((package = vpi_scan(iterator)) != NULL) {
        PLI_BYTE8 *name = vpi_get_str(vpiName, package);
        if (name != NULL && strcmp((const char *)name, "lookup_namespace") == 0) {
            vpi_release_handle(iterator);
            return package;
        }
    }
    return NULL;
}

static int int_value(vpiHandle object)
{
    s_vpi_value value = {0};
    if (object == NULL)
        return -1;
    value.format = vpiIntVal;
    vpi_get_value(object, &value);
    return value.value.integer;
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call == NULL ? NULL : vpi_handle(vpiScope, call);
    vpiHandle package = find_package();
    vpiHandle module_data, package_data, imported_data, unit_data, explicit_unit;
    (void)unused;
    if (scope == NULL || package == NULL) {
        vpi_printf("module or package not found\n");
        return 0;
    }
    module_data = vpi_handle_by_name((PLI_BYTE8 *)"module_data", scope);
    package_data = vpi_handle_by_name((PLI_BYTE8 *)"imported_data", package);
    imported_data = vpi_handle_by_name((PLI_BYTE8 *)"imported_data", scope);
    unit_data = vpi_handle_by_name((PLI_BYTE8 *)"unit_data", scope);
    explicit_unit = vpi_handle_by_name((PLI_BYTE8 *)"$unit::unit_data", NULL);
    vpi_printf("VPI module=%d package=%d imported=%d unit=%d explicit-unit=%d\n",
               int_value(module_data), int_value(package_data), imported_data != NULL,
               unit_data != NULL, explicit_unit != NULL);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_visible_names";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
