#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void observe_vector(vpiHandle top, const char *name)
{
    vpiHandle parent = vpi_handle_by_name((PLI_BYTE8 *)name, top);
    PLI_INT32 parent_flag;
    int bit_objects = 0, equal_flags = 0;

    if (parent == NULL) {
        vpi_printf("%s not found\n", name);
        return;
    }
    parent_flag = vpi_get(vpiExpanded, parent);
    for (int index = 4; index <= 6; index++) {
        vpiHandle bit = vpi_handle_by_index(parent, index);
        if (bit != NULL && vpi_get(vpiType, bit) == vpiNetBit) {
            bit_objects++;
            equal_flags += vpi_get(vpiExpanded, bit) == parent_flag;
        }
    }
    vpi_printf("%s parent_boolean=%d bit_objects=%d equal_flags=%d\n",
               name, parent_flag == 0 || parent_flag == 1, bit_objects, equal_flags);
}

static PLI_INT32 observe(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_net_bits_share_parent_expansion_property", NULL);
    (void)data;
    if (top != NULL) {
        observe_vector(top, "basic_net");
        observe_vector(top, "advisory_net");
    }
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
