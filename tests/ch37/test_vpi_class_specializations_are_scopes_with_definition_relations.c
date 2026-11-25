#include <stddef.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#if defined(vpiClassDefn) && defined(vpiClassTypespec)
#define TOP "test_vpi_class_specializations_are_scopes_with_definition_relations"

static vpiHandle find(PLI_INT32 relation, vpiHandle owner, const char *name)
{
    vpiHandle iterator = vpi_iterate(relation, owner);
    vpiHandle item;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        const char *actual = vpi_get_str(vpiName, item);
        if (actual != NULL && strcmp(name, actual) == 0) {
            vpi_release_handle(iterator);
            return item;
        }
    }
    return NULL;
}

static void report_specialization(const char *path, const char *label)
{
    vpiHandle variable = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    vpiHandle typespec = variable != NULL ? vpi_handle(vpiTypespec, variable) : NULL;
    const int scope = typespec != NULL && vpi_get(vpiType, typespec) == vpiClassTypespec;
    const char *name = scope ? vpi_get_str(vpiName, typespec) : NULL;
    const int named = name != NULL && *name != '\0';
    vpiHandle instance_value = scope ? find(vpiVariables, typespec, "instance_value") : NULL;
    vpiHandle shared_value = scope ? find(vpiVariables, typespec, "shared_value") : NULL;
    vpi_printf("%s class scope=%d name=%d instance width=%d shared property=%d\n",
               label, scope, named, instance_value != NULL ? (int)vpi_get(vpiSize, instance_value) : -1,
               shared_value != NULL);
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    report_specialization(TOP ".narrow_object", "narrow");
    report_specialization(TOP ".wide_object", "wide");

    vpiHandle defn = find(vpiClassDefn, NULL, "sized_scope");
    vpiHandle scope = defn != NULL ? find(vpiInternalScope, defn, "sample") : NULL;
    vpiHandle owner = scope != NULL ? vpi_handle(vpiClassDefn, scope) : NULL;
    vpi_printf("class definition internal scope=%d reverse definition=%d\n",
               scope != NULL && vpi_get(vpiType, scope) == vpiFunction,
               owner != NULL && vpi_compare_objects(owner, defn));
    return 0;
}
#else
static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("class scope declarations unavailable\n");
    return 0;
}
#endif

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_class_scope_relations";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
