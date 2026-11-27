/* Apply the diagram's common properties and edges to real objects in each group. */
#include <stddef.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_diagram_access"

#if defined(vpiInstance) && defined(vpiPackage) && defined(vpiInterface) && defined(vpiProgram)
typedef struct {
    const char *label;
    const char *name;
    const char *full_name;
    PLI_INT32 type;
} instance_kind;

static int same(vpiHandle first, vpiHandle second)
{
    return first && second && vpi_compare_objects(first, second);
}

static int property_matches(vpiHandle object, PLI_INT32 property, const char *expected)
{
    const PLI_BYTE8 *actual = object ? vpi_get_str(property, object) : NULL;
    return actual && strcmp(actual, expected) == 0;
}

static int read_int(vpiHandle object)
{
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(object, &value);
    return value.value.integer;
}

static vpiHandle root_package(vpiHandle module)
{
    const vpiHandle iterator = vpi_iterate(vpiInstance, NULL);
    vpiHandle item, package = NULL;
    int top_visits = 0, package_visits = 0, nested = 0;
    while (iterator && (item = vpi_scan(iterator))) {
        top_visits += same(item, module);
        if (vpi_get(vpiType, item) == vpiPackage &&
            property_matches(item, vpiName, "diagram_group_package")) {
            package = item;
            ++package_visits;
        }
        nested += property_matches(item, vpiName, "local_if")
               || property_matches(item, vpiName, "local_program")
               || property_matches(item, vpiName, "local_module");
    }
    vpi_printf((PLI_BYTE8 *)"root instance iterator module=%d package=%d nested=%d\n",
               top_visits, package_visits, nested);
    return package;
}

static void show_instance(vpiHandle instance, const instance_kind *kind)
{
    const int type = instance && vpi_get(vpiType, instance) == kind->type;
    const int name = property_matches(instance, vpiName, kind->name);
    const int path = property_matches(instance, vpiFullName, kind->full_name);
    int count = 0, value = -1, owner = 0;
    const vpiHandle iterator = instance ? vpi_iterate(vpiVariables, instance) : NULL;
    const int iterator_type = iterator && vpi_get(vpiType, iterator) == vpiIterator;
    vpiHandle item;
    while (iterator && (item = vpi_scan(iterator))) {
        if (!property_matches(item, vpiName, "sample_value"))
            continue;
        ++count;
        value = read_int(item);
        owner += same(vpi_handle(vpiInstance, item), instance);
    }
    vpi_printf((PLI_BYTE8 *)"%s type=%d name=%d full-name=%d iterator=%d matching=%d value=%d owner=%d\n",
               kind->label, type, name, path, iterator_type, count, value, owner);
}

static void show_nets(vpiHandle module)
{
    const vpiHandle iterator = module ? vpi_iterate(vpiNet, module) : NULL;
    vpiHandle item, scalar = NULL, vector = NULL;
    int count = 0;
    while (iterator && (item = vpi_scan(iterator))) {
        if (vpi_get(vpiType, item) != vpiNet)
            continue;
        ++count;
        if (property_matches(item, vpiName, "scalar_net"))
            scalar = item;
        else if (property_matches(item, vpiName, "vector_net"))
            vector = item;
    }
    vpi_printf((PLI_BYTE8 *)"net iterator count=%d distinct=%d\n", count, scalar && vector && !same(scalar, vector));
    if (!scalar || !vector)
        return;
    vpi_printf((PLI_BYTE8 *)"scalar vector=%d size=%d owner=%d\n", vpi_get(vpiVector, scalar),
               vpi_get(vpiSize, scalar), same(vpi_handle(vpiModule, scalar), module));
    vpi_printf((PLI_BYTE8 *)"vector vector=%d size=%d owner=%d\n", vpi_get(vpiVector, vector),
               vpi_get(vpiSize, vector), same(vpi_handle(vpiModule, vector), module));
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    const instance_kind package = {"package", "diagram_group_package", "diagram_group_package::", vpiPackage};
    const instance_kind iface = {"interface", "local_if", TOP ".local_if", vpiInterface};
    const instance_kind program = {"program", "local_program", TOP ".local_program", vpiProgram};
    const instance_kind module = {"module", "local_module", TOP ".local_module", vpiModule};
    const vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    const vpiHandle local_module = top ? vpi_handle_by_name((PLI_BYTE8 *)module.name, top) : NULL;
    show_instance(root_package(top), &package);
    show_instance(top ? vpi_handle_by_name((PLI_BYTE8 *)iface.name, top) : NULL, &iface);
    show_instance(top ? vpi_handle_by_name((PLI_BYTE8 *)program.name, top) : NULL, &program);
    show_instance(local_module, &module);
    show_nets(local_module);
    return 0;
}
#else
static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf((PLI_BYTE8 *)"instance group VPI declarations unavailable\n");
    return 0;
}
#endif

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_diagram_access";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
