/* Compare the instance and compatibility module links for specify paths. */
#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 probe(PLI_BYTE8 *unused)
{
    (void)unused;
#if defined(vpiInstance) && defined(vpiInterface) && defined(vpiModPath)
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle arguments = call == NULL ? NULL : vpi_iterate(vpiArgument, call);
    vpiHandle target = arguments == NULL ? NULL : vpi_scan(arguments);
    if (target == NULL) {
        vpi_printf("specify owner argument missing\n");
        return 0;
    }
    s_vpi_value name = {0};
    name.format = vpiStringVal;
    vpi_get_value(target, &name);
    vpiHandle owner = name.value.str == NULL ? NULL : vpi_handle_by_name(name.value.str, NULL);
    vpi_release_handle(arguments);
    if (owner == NULL) {
        vpi_printf("specify owner not found\n");
        return 0;
    }

    PLI_INT32 kind = vpi_get(vpiType, owner);
    const char *kind_text = kind == vpiInterface ? "interface" :
                            kind == vpiModule ? "module" : "other";
    vpiHandle iterator = vpi_iterate(vpiModPath, owner);
    vpiHandle known[4];
    int distinct = 0;
    int paths = 0;
    int instance_matches = 0;
    int module_matches = 0;
    int module_nulls = 0;
    vpiHandle path;
    while (iterator != NULL && (path = vpi_scan(iterator)) != NULL) {
        if (vpi_get(vpiType, path) != vpiModPath)
            continue;
        int index;
        for (index = 0; index < distinct; ++index) {
            if (vpi_compare_objects(path, known[index]))
                break;
        }
        if (index == distinct && distinct < (int)(sizeof known / sizeof known[0]))
            known[distinct++] = path;
        ++paths;
        vpiHandle instance = vpi_handle(vpiInstance, path);
        vpiHandle module = vpi_handle(vpiModule, path);
        instance_matches += instance != NULL && vpi_compare_objects(instance, owner);
        module_matches += module != NULL && vpi_compare_objects(module, owner);
        module_nulls += module == NULL;
    }
    vpi_printf("specify %s paths=%d distinct=%d instance=%d module=%d module-null=%d\n",
               kind_text, paths, distinct, instance_matches, module_matches, module_nulls);
#else
    vpi_printf("interface path declarations unavailable\n");
#endif
    return 0;
}

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_specify_owner";
    task.calltf = probe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
