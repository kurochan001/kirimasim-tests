/* VPI application of test_vpi_nba_synch_callback_data (IEEE 1800-2023 38.36.2). */
#include <string.h>
#include "vpi_user.h"

/* The value that Annex K gives, for vpi_user.h files that leave it out. */
#ifndef cbNBASynch
#define cbNBASynch 30
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_nba_synch_callback_data"

/* A value whose format no table defines: a time callback ignores it. */
static s_vpi_value ignored_value;
/* The structure given to vpi_register_cb; it stays allocated. */
static s_cb_data request;
static s_vpi_time request_time;
static char name[] = "NBA synch 10";

static int value_of(const char *full)
{
    vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    s_vpi_value v;

    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 on_time(p_cb_data cb)
{
    if (cb->time == NULL || cb->time->type != vpiSimTime)
        vpi_printf("%s: no simulation time\n", cb->user_data);
    else
        vpi_printf("%d: %s, a=%d b=%d, new structure: %s, registered reason: %s\n",
                   (int)cb->time->low, cb->user_data, value_of(TOP ".a"), value_of(TOP ".b"),
                   cb != &request ? "yes" : "no", cb->reason == cbNBASynch ? "yes" : "no");
    return 0;
}

static PLI_INT32 on_start(p_cb_data cb)
{
    (void)cb;
    ignored_value.format = 12345;
    request_time.type = vpiSimTime;
    request_time.high = 0;
    request_time.low = 10;
    memset(&request, 0, sizeof request);
    request.reason = cbNBASynch;
    request.cb_rtn = on_time;
    request.time = &request_time;
    request.value = &ignored_value;
    request.user_data = name;
    if (vpi_register_cb(&request) == NULL)
        vpi_printf("%s: not registered\n", name);
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
