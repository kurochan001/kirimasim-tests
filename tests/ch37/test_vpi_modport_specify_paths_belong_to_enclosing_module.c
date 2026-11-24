#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void report(const char *label, vpiHandle owner)
{
    vpiHandle iterator = owner != NULL ? vpi_iterate(vpiModPath, owner) : NULL;
    vpiHandle path;
    int objects = 0, paths = 0, instance_owners = 0;
    int module_handles = 0, module_owners = 0;
    while (iterator != NULL && (path = vpi_scan(iterator)) != NULL) {
        vpiHandle instance = vpi_handle(vpiInstance, path);
        vpiHandle module = vpi_handle(vpiModule, path);
        ++objects;
        paths += vpi_get(vpiType, path) == vpiModPath;
        instance_owners += instance != NULL && vpi_compare_objects(instance, owner);
        module_handles += module != NULL;
        module_owners += module != NULL && vpi_compare_objects(module, owner);
    }
    vpi_printf("%s found=%d objects=%d paths=%d instance owners=%d legacy handles=%d matching=%d\n",
               label, owner != NULL, objects, paths, instance_owners, module_handles, module_owners);
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle scope = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_modport_specify_paths_belong_to_enclosing_module", NULL);
    (void)unused;
    if (scope != NULL) {
        report("interface", vpi_handle_by_name((PLI_BYTE8 *)"bus", scope));
        report("modport module", vpi_handle_by_name((PLI_BYTE8 *)"modport_cell", scope));
        report("module", vpi_handle_by_name((PLI_BYTE8 *)"reference_cell", scope));
    }
    return 0;
}

static void register_probe(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$probe_path_owners";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_probe, NULL};

#ifdef __cplusplus
}
#endif
