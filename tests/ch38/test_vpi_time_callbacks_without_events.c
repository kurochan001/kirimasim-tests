/* VPI application of test_vpi_time_callbacks_without_events (IEEE 1800-2023 38.36.2). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_time_callbacks_without_events"

/* A value whose format no table defines: a time callback ignores it. */
static s_vpi_value ignored_value;
/* The structures given to vpi_register_cb; they stay allocated. */
#define REQUESTS 8
static s_cb_data requests[REQUESTS];
static s_vpi_time request_times[REQUESTS];

static int value_of(const char *name)
{
    vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    s_vpi_value v;

    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 on_time(p_cb_data cb);

static void request(int k, PLI_INT32 reason, PLI_UINT32 when, const char *name)
{
    memset(&requests[k], 0, sizeof requests[k]);
    request_times[k].type = vpiSimTime;
    request_times[k].high = 0;
    request_times[k].low = when;
    requests[k].reason = reason;
    requests[k].cb_rtn = on_time;
    requests[k].time = &request_times[k];
    requests[k].value = &ignored_value;
    requests[k].user_data = (PLI_BYTE8 *)name;
    if (vpi_register_cb(&requests[k]) == NULL)
        vpi_printf("%s: not registered\n", name);
}

static PLI_INT32 on_time(p_cb_data cb)
{
    int k, fresh = 1, reason_ok = 0;

    for (k = 0; k < REQUESTS; k++)
        if (cb == &requests[k])
            fresh = 0;
    for (k = 0; k < REQUESTS; k++)
        if (requests[k].user_data == cb->user_data && requests[k].reason == cb->reason)
            reason_ok = 1;
    if (cb->time == NULL || cb->time->type != vpiSimTime)
        vpi_printf("%s: no simulation time\n", cb->user_data);
    else
        vpi_printf("%d: %s, v=%d w=%d, new structure: %s, registered reason: %s\n",
                   (int)cb->time->low, cb->user_data, value_of(TOP ".v"), value_of(TOP ".w"),
                   fresh ? "yes" : "no", reason_ok ? "yes" : "no");
    if (strcmp(cb->user_data, "after delay 25") == 0)
        request(7, cbNextSimTime, 2, "next sim time");
    return 0;
}

static PLI_INT32 on_start(p_cb_data cb)
{
    (void)cb;
    ignored_value.format = 12345;
    request(0, cbAtStartOfSimTime, 10, "start of time 10");
    request(1, cbAtStartOfSimTime, 15, "start of time 15");
    request(2, cbAfterDelay, 20, "after delay 20");
    request(3, cbAfterDelay, 25, "after delay 25");
    request(4, cbAtEndOfSimTime, 30, "end of time 30");
    request(5, cbReadWriteSynch, 35, "read-write synch 35");
    request(6, cbReadOnlySynch, 35, "read-only synch 35");
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
