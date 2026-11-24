#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int property(PLI_INT32 key, vpiHandle object)
{
    return object != NULL ? (int)vpi_get(key, object) : -1;
}

static void check_membership(vpiHandle scope, const char *label, const char *single_name,
                             const char *array_name, PLI_INT32 index)
{
    vpiHandle single = vpi_handle_by_name((PLI_BYTE8 *)single_name, scope);
    vpiHandle array = vpi_handle_by_name((PLI_BYTE8 *)array_name, scope);
    vpiHandle element = array != NULL ? vpi_handle_by_index(array, index) : NULL;
    vpi_printf("%s legacy=%d/%d member=%d/%d\n", label,
               property(vpiArray, single), property(vpiArray, element),
               property(vpiArrayMember, single), property(vpiArrayMember, element));
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle scope = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_legacy_array_property_on_variable_elements", NULL);
    (void)unused;
    if (scope != NULL) {
        check_membership(scope, "logic", "standalone_logic", "logic_rows", 4);
        check_membership(scope, "int", "standalone_int", "int_rows", -2);
    }
    return 0;
}

static void register_probe(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$probe_array_vars";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_probe, NULL};

#ifdef __cplusplus
}
#endif
