/* VPI application of test_vpi_assertion_kill_keeps_past_sampling (IEEE 1800-2023 39.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_kill_keeps_past_sampling"
#define MAX 32

struct event {
    int when;
    int rank;
    int start;
};

static const char *const names[] = {"attempt killed", "success", "failure"};
static struct event events[MAX];
static int n_events;
static vpiHandle a1;

static int ticks(p_vpi_time t)
{
    return t != NULL ? (int)t->low : -1;
}

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_assertion(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                              p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    struct event *e;

    (void)assertion;
    (void)user_data;
    if (n_events >= MAX)
        return 0;
    e = &events[n_events++];
    e->when = cb_time != NULL ? ticks(cb_time) : now();
    e->rank = reason == cbAssertionKill ? 0 : reason == cbAssertionSuccess ? 1 : 2;
    e->start = (reason == cbAssertionSuccess || reason == cbAssertionFailure) && info != NULL
               ? ticks(&info->attemptStartTime) : -1;
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    static const PLI_INT32 reasons[] = {cbAssertionSuccess, cbAssertionFailure, cbAssertionKill};
    int i;

    (void)user_data;
    a1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a1", NULL);
    if (a1 == NULL) {
        vpi_printf((PLI_BYTE8 *)"a1 not found\n");
        return 0;
    }
    for (i = 0; i < 3; i++)
        if (vpi_register_assertion_cb(a1, reasons[i], on_assertion, NULL) == NULL)
            vpi_printf((PLI_BYTE8 *)"a1: callback %d not placed\n", i);
    return 0;
}

static PLI_INT32 kill_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;
    s_vpi_time start;

    (void)user_data;
    if (arg == NULL || a1 == NULL) {
        vpi_printf((PLI_BYTE8 *)"$vt_kill: no argument or no assertion\n");
        return 0;
    }
    vpi_release_handle(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    memset(&start, 0, sizeof start);
    start.type = vpiSimTime;
    start.high = 0;
    start.low = (PLI_UINT32)v.value.integer;
    vpi_control(vpiAssertionKill, a1, &start);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa;
    const struct event *b = (const struct event *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    if (a->rank != b->rank)
        return a->rank - b->rank;
    return a->start - b->start;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    qsort(events, n_events, sizeof events[0], by_time);
    for (i = 0; i < n_events; i++) {
        if (events[i].rank == 0)
            vpi_printf((PLI_BYTE8 *)"%d: a1 %s\n", events[i].when, names[0]);
        else
            vpi_printf((PLI_BYTE8 *)"%d: a1 %s, attempt started at %d\n", events[i].when,
                       names[events[i].rank], events[i].start);
    }
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add_task("$vt_watch", watch_calltf);
    add_task("$vt_kill", kill_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
