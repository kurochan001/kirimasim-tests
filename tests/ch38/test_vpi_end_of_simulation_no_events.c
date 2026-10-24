/* VPI application of test_vpi_end_of_simulation_no_events (IEEE 1800-2023 38.36.3). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char the_end[] = "the end";

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_start(p_cb_data cb)
{
    vpi_printf((PLI_BYTE8 *)"start of simulation at %d: reason cbStartOfSimulation %d, "
               "user_data NULL %d\n", now(), cb->reason == cbStartOfSimulation,
               cb->user_data == NULL);
    return 0;
}

static PLI_INT32 on_end(p_cb_data cb)
{
    s_vpi_value v;
    vpiHandle r = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_end_of_simulation_no_events.r", NULL);

    v.format = vpiIntVal;
    v.value.integer = -1;
    if (r != NULL)
        vpi_get_value(r, &v);
    vpi_printf((PLI_BYTE8 *)"end of simulation at %d: reason cbEndOfSimulation %d, "
               "user_data \"%s\", r = %d\n", now(), cb->reason == cbEndOfSimulation,
               cb->user_data != NULL ? cb->user_data : "(null)", (int)v.value.integer);
    return 0;
}

static void register_actions(void)
{
    s_cb_data cb;

    /* Only reason, cb_rtn and user_data are set; everything else is 0. */
    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfSimulation;
    cb.cb_rtn = on_end;
    cb.user_data = the_end;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_actions, 0};

#ifdef __cplusplus
}
#endif
