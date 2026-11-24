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
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_legacy_array_property_on_net_elements", NULL);
    vpiHandle scalar_net, net_array, net;
    (void)data;
    if (top == NULL)
        return 0;

    scalar_net = vpi_handle_by_name((PLI_BYTE8 *)"individual_net", top);
    net_array = vpi_handle_by_name((PLI_BYTE8 *)"array_net", top);
    net = net_array != NULL ? vpi_handle_by_index(net_array, 5) : NULL;

    report("nets", scalar_net, net);
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
