#include <stddef.h>
#include <stdio.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void deposit(const char *item)
{
    const char *top = "test_vpi_net_array_deposit_works_from_system_task_and_timing_callback";
    char full_name[128];
    PLI_INT32 start_index[] = {1};
    PLI_INT32 values[] = {0xa5, 0xc3};
    s_vpi_arrayvalue pair = {0};

    snprintf(full_name, sizeof full_name, "%s.%s", top, item);
    vpiHandle target = vpi_handle_by_name(full_name, NULL);
    if (target == NULL) {
        vpi_printf("%s not found\n", item);
        return;
    }
    pair.format = vpiIntVal;
    pair.value.integers = values;
    vpi_put_value_array(target, &pair, start_index, 2);
}

static PLI_INT32 via_task(PLI_BYTE8 *unused)
{
    (void)unused;
    deposit("task_wires");
    return 0;
}

static PLI_INT32 via_callback(p_cb_data unused)
{
    (void)unused;
    deposit("callback_wires");
    return 0;
}

static void register_all(void)
{
    s_vpi_time scheduled = {0};
    s_cb_data cb = {0};
    s_vpi_systf_data task = {0};

    scheduled.type = vpiSimTime;
    scheduled.low = 2;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = via_callback;
    cb.time = &scheduled;
    vpi_register_cb(&cb);

    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$deposit_from_system_task";
    task.calltf = via_task;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_all, NULL};

#ifdef __cplusplus
}
#endif
