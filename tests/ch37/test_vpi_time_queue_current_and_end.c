/* VPI application of test_vpi_time_queue_current_and_end (IEEE 1800-2023 37.81). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Prints the times of vpi_iterate(vpiTimeQueue, NULL) in the order returned. */
static PLI_INT32 show_queue(p_cb_data data)
{
    s_vpi_time t;
    vpiHandle it, q;

    vpi_printf((PLI_BYTE8 *)"%s:", data->user_data);
    it = vpi_iterate(vpiTimeQueue, NULL);
    if (it == NULL) {
        vpi_printf((PLI_BYTE8 *)" iterator NULL\n");
        return 0;
    }
    while ((q = vpi_scan(it)) != NULL) {
        t.type = vpiSimTime;
        vpi_get_time(q, &t);
        vpi_printf((PLI_BYTE8 *)" %u", (unsigned)t.low);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static void at(PLI_INT32 reason, PLI_UINT32 time, const char *label)
{
    static s_vpi_time times[3];
    static int n;
    s_cb_data d;

    memset(&d, 0, sizeof d);
    times[n].type = vpiSimTime;
    times[n].high = 0;
    times[n].low = time;
    d.reason = reason;
    d.cb_rtn = show_queue;
    d.time = &times[n++];
    d.user_data = (PLI_BYTE8 *)label;
    vpi_register_cb(&d);
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    (void)data;
    at(cbAtStartOfSimTime, 5, "start of time 5");
    at(cbReadOnlySynch, 5, "read-only synch of time 5");
    at(cbReadOnlySynch, 25, "read-only synch of time 25");
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = start_of_simulation;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
