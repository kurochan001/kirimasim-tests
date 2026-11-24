#ifndef TEST_CHECKPOINT_RESET_TRACE_H
#define TEST_CHECKPOINT_RESET_TRACE_H

#include <stddef.h>
#include "action_callback.h"

static int read_reset_signal(const char *name)
{
    vpiHandle handle = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    s_vpi_value value = {0};
    if (handle == NULL)
        return -1;
    value.format = vpiIntVal;
    vpi_get_value(handle, &value);
    return value.value.integer;
}

static unsigned tick(void)
{
    s_vpi_time time = {0};
    time.type = vpiSimTime;
    vpi_get_time(NULL, &time);
    return time.low;
}

static void report_reset_state(const char *event)
{
    vpi_printf("%s t=%u state=%d net=%d\n", event, tick(),
               read_reset_signal(RESET_TEST_TOP ".state"),
               read_reset_signal(RESET_TEST_TOP ".mirrored_state"));
}

static PLI_INT32 reset_action(p_cb_data callback)
{
    report_reset_state(callback->reason == cbStartOfReset ? "start reset" : "end reset");
    return 0;
}

static void trace_reset(void)
{
    register_action(cbStartOfReset, reset_action, NULL);
    register_action(cbEndOfReset, reset_action, NULL);
}

#endif
