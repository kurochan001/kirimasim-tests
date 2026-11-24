#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 deposit(p_cb_data unused)
{
    const char *name = "test_vpi_bulk_net_deposit_clears_when_equal_resolution_driver_changes.bus";
    vpiHandle bus = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    PLI_INT32 index[] = {4};
    PLI_INT32 values[] = {2, 13};
    s_vpi_arrayvalue array_value = {0};
    (void)unused;
    if (bus == NULL) {
        vpi_printf("bus not found\n");
        return 0;
    }
    array_value.format = vpiIntVal;
    array_value.value.integers = values;
    vpi_put_value_array(bus, &array_value, index, 2);
    return 0;
}

static void register_deposit(void)
{
    s_cb_data cb = {0};
    s_vpi_time scheduled = {0};
    scheduled.type = vpiSimTime;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = deposit;
    cb.time = &scheduled;
    scheduled.low = 2;
    vpi_register_cb(&cb);
    scheduled.low = 5;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_deposit, NULL};

#ifdef __cplusplus
}
#endif
