/* VPI application of test_vpi_remove_cb_in_callback (IEEE 1800-2023 38.39). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle once_cb, delay_cb, second_end_cb;
static int once_calls, every_calls, once_removed = -1, delay_removed = -1, end_removed = -1;

static PLI_INT32 on_once(p_cb_data data)
{
    (void)data;
    once_calls++;
    if (once_calls == 1)
        once_removed = vpi_remove_cb(once_cb);
    return 0;
}

static PLI_INT32 on_every(p_cb_data data)
{
    (void)data;
    every_calls++;
    if (every_calls == 2) {
        delay_removed = vpi_remove_cb(delay_cb);
        end_removed = vpi_remove_cb(second_end_cb);
    }
    return 0;
}

static PLI_INT32 on_delay(p_cb_data data)
{
    (void)data;
    vpi_printf("the removed time callback runs\n");
    return 0;
}

static PLI_INT32 on_first_end(p_cb_data data)
{
    (void)data;
    vpi_printf("once: %d call(s), removing itself returned %d\n", once_calls, once_removed);
    vpi_printf("every: %d call(s), removing the time callback returned %d, "
               "removing the end callback returned %d\n", every_calls, delay_removed,
               end_removed);
    return 0;
}

static PLI_INT32 on_second_end(p_cb_data data)
{
    (void)data;
    vpi_printf("the removed end of simulation callback runs\n");
    return 0;
}

static vpiHandle place(PLI_INT32 reason, vpiHandle obj, PLI_INT32 (*routine)(p_cb_data),
                       PLI_UINT32 delay)
{
    static s_vpi_time time_kind;
    static s_vpi_value value_kind;
    s_cb_data d;

    time_kind.type = vpiSimTime;
    time_kind.high = 0;
    time_kind.low = delay;
    value_kind.format = vpiIntVal;
    memset(&d, 0, sizeof d);
    d.reason = reason;
    d.cb_rtn = routine;
    d.obj = obj;
    if (reason != cbEndOfSimulation) {
        d.time = &time_kind;
        d.value = &value_kind;
    }
    return vpi_register_cb(&d);
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle r = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_remove_cb_in_callback.r", NULL);

    (void)data;
    if (r == NULL) {
        vpi_printf("r not found\n");
        return 0;
    }
    once_cb = place(cbValueChange, r, on_once, 0);
    place(cbValueChange, r, on_every, 0);
    delay_cb = place(cbAfterDelay, NULL, on_delay, 5);
    place(cbEndOfSimulation, NULL, on_first_end, 0);
    second_end_cb = place(cbEndOfSimulation, NULL, on_second_end, 0);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
