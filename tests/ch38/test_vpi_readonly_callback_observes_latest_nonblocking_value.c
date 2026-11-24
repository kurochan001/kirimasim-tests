#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 read_after_nba(p_cb_data data)
{
    s_vpi_value value = {0};
    vpiHandle sample = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_readonly_callback_observes_latest_nonblocking_value.sample", NULL);
    (void)data;

    if (sample == NULL) {
        vpi_printf("sample not found\n");
        return 0;
    }
    value.format = vpiIntVal;
    vpi_get_value(sample, &value);
    vpi_printf("readonly=%d\n", (int)value.value.integer);
    return 0;
}

static PLI_INT32 schedule(p_cb_data data)
{
    static s_vpi_time at_two = {vpiSimTime, 0, 2, 0.0};
    s_cb_data callback = {0};
    (void)data;

    callback.reason = cbReadOnlySynch;
    callback.cb_rtn = read_after_nba;
    callback.time = &at_two;
    vpi_register_cb(&callback);
    return 0;
}

static void register_check(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = schedule;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_check, NULL};

#ifdef __cplusplus
}
#endif
