#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_bulk_propagation_suppressed_then_restored"

static vpiHandle array_object;

static PLI_INT32 update_array(p_cb_data cb)
{
    s_vpi_arrayvalue value;
    PLI_INT32 start[1] = {0};
    PLI_INT32 quiet_values[2] = {31, 47};
    PLI_INT32 active_values[2] = {32, 48};
    int quiet = strcmp((const char *)cb->user_data, "quiet") == 0;

    memset(&value, 0, sizeof value);
    value.format = vpiIntVal;
    value.flags = quiet ? vpiPropagateOff : vpiNoDelay;
    value.value.integers = quiet ? quiet_values : active_values;
    vpi_put_value_array(array_object, &value, start, 2);
    return 0;
}

static PLI_INT32 start_simulation(p_cb_data cb)
{
    static s_vpi_time times[2];
    static const char *const tags[2] = {"quiet", "active"};
    const char *full_name;
    s_cb_data registration;
    int index;

    (void)cb;
    array_object = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a", NULL);
    full_name = array_object != NULL ? vpi_get_str(vpiFullName, array_object) : NULL;
    if (full_name == NULL || strcmp(full_name, TOP ".a") != 0) {
        vpi_printf((PLI_BYTE8 *)"array identity lookup failed\n");
        return 0;
    }

    for (index = 0; index < 2; index++) {
        memset(&registration, 0, sizeof registration);
        memset(&times[index], 0, sizeof times[index]);
        times[index].type = vpiSimTime;
        times[index].low = index == 0 ? 10 : 20;
        registration.reason = cbAfterDelay;
        registration.cb_rtn = update_array;
        registration.time = &times[index];
        registration.user_data = (PLI_BYTE8 *)tags[index];
        if (vpi_register_cb(&registration) == NULL)
            vpi_printf((PLI_BYTE8 *)"array update callback not registered\n");
    }
    return 0;
}

static void register_application(void)
{
    s_cb_data registration;
    memset(&registration, 0, sizeof registration);
    registration.reason = cbStartOfSimulation;
    registration.cb_rtn = start_simulation;
    if (vpi_register_cb(&registration) == NULL)
        vpi_printf((PLI_BYTE8 *)"startup callback not registered\n");
}

void (*vlog_startup_routines[])(void) = {register_application, 0};

#ifdef __cplusplus
}
#endif
