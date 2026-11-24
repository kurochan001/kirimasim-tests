#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int property(PLI_INT32 property_id, vpiHandle object)
{
    return object != NULL ? (int)vpi_get(property_id, object) : -1;
}

static void report(const char *label, vpiHandle single, vpiHandle member)
{
    vpi_printf("%s legacy=%d/%d member=%d/%d\n", label,
               property(vpiArray, single), property(vpiArray, member),
               property(vpiArrayMember, single), property(vpiArrayMember, member));
}

static PLI_INT32 observe(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_legacy_array_property_on_module_instances", NULL);
    vpiHandle scalar_instance, instance;
    (void)data;
    if (top == NULL)
        return 0;

    scalar_instance = vpi_handle_by_name((PLI_BYTE8 *)"scalar_instance", top);
    instance = vpi_handle_by_name((PLI_BYTE8 *)"instances[5]", top);

    report("instances", scalar_instance, instance);
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
