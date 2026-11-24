#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

enum { OBJECTS = 3 };

struct scope_links {
    int count;
    vpiHandle found[OBJECTS];
};

static struct scope_links collect(PLI_INT32 relation, vpiHandle top)
{
    const char *const names[OBJECTS] = {"chosen", "links[3]", "links[4]"};
    vpiHandle iter = vpi_iterate(relation, top), object;
    struct scope_links objects = {0, {NULL, NULL, NULL}};
    while (iter != NULL && (object = vpi_scan(iter)) != NULL) {
        const char *name = vpi_get_str(vpiName, object);
        ++objects.count;
        if (name == NULL)
            continue;
        for (int i = 0; i < OBJECTS; ++i) {
            if (strcmp(name, names[i]) == 0) {
                objects.found[i] = object;
                break;
            }
        }
    }
    return objects;
}

static int belongs_to(vpiHandle object, vpiHandle top)
{
    vpiHandle scope = object != NULL ? vpi_handle(vpiScope, object) : NULL;
    return scope != NULL && vpi_compare_objects(scope, top);
}

static PLI_INT32 probe(PLI_BYTE8 *data)
{
    vpiHandle top = vpi_handle_by_name(
        "test_vpi_deprecated_interface_iteration_matches_current_handles", NULL);
    (void)data;
    if (top == NULL) {
        vpi_printf("top not found\n");
        return 0;
    }

    struct scope_links old = collect(vpiInterfaceDecl, top);
    struct scope_links current = collect(vpiVirtualInterfaceVar, top);
    int identical = 0, typed = 0, scoped = 0;
    for (int i = 0; i < OBJECTS; ++i) {
        vpiHandle a = old.found[i], b = current.found[i];
        identical += a != NULL && b != NULL && vpi_compare_objects(a, b);
        typed += a != NULL && b != NULL && vpi_get(vpiType, a) == vpiVirtualInterfaceVar
            && vpi_get(vpiType, b) == vpiVirtualInterfaceVar;
        scoped += belongs_to(a, top) && belongs_to(b, top);
    }
    vpi_printf("old=%d current=%d same=%d typed=%d scoped=%d\n",
               old.count, current.count, identical, typed, scoped);
    return 0;
}

static void register_probe(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$probe_interface_iterators";
    task.calltf = probe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_probe, NULL};

#ifdef __cplusplus
}
#endif
