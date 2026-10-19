/* VPI application of test_vpi_assertion_kill_reset (IEEE 1800-2023 39.5.2, 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 32

struct event {
    int when;
    int rank;
    int start;
    int info_null;
};

static const char *const reasons[] = {"attempt killed", "reset", "success", "failure"};

static struct event events[MAX];
static int n_events;
static vpiHandle a1, kill_cb;

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)(t->real + 0.5);
    return (int)t->low;
}

static PLI_INT32 on_assertion(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                              p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    struct event *e;

    (void)assertion;
    (void)user_data;
    if (n_events == MAX)
        return 0;
    e = &events[n_events++];
    e->when = ticks(cb_time);
    e->info_null = info == NULL;
    e->start = -1;
    switch (reason) {
    case cbAssertionKill: e->rank = 0; break;
    case cbAssertionReset: e->rank = 1; break;
    case cbAssertionSuccess: e->rank = 2; break;
    case cbAssertionFailure: e->rank = 3; break;
    default: e->rank = -1; break;
    }
    if ((reason == cbAssertionSuccess || reason == cbAssertionFailure) && info != NULL)
        e->start = ticks(&info->attemptStartTime);
    return 0;
}

static vpiHandle place(PLI_INT32 reason)
{
    vpiHandle cb = vpi_register_assertion_cb(a1, reason, on_assertion, NULL);
    if (cb == NULL)
        vpi_printf("callback %d not placed\n", (int)reason);
    return cb;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    a1 = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_assertion_kill_reset.a1", NULL);
    if (a1 == NULL) {
        vpi_printf("a1 not found\n");
        return 0;
    }
    kill_cb = place(cbAssertionKill);
    place(cbAssertionReset);
    place(cbAssertionSuccess);
    place(cbAssertionFailure);
    return 0;
}

static PLI_INT32 kill_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;
    s_vpi_time start;

    (void)user_data;
    if (arg == NULL || a1 == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    start.type = vpiSimTime;
    start.high = 0;
    start.low = (PLI_UINT32)v.value.integer;
    vpi_control(vpiAssertionKill, a1, &start);
    return 0;
}

static PLI_INT32 reset_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (a1 == NULL)
        return 0;
    if (kill_cb != NULL)
        vpi_remove_cb(kill_cb);
    vpi_control(vpiAssertionReset, a1);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa, *b = (const struct event *)pb;
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
        const struct event *e = &events[i];
        const char *what = e->rank >= 0 ? reasons[e->rank] : "other reason";
        if (e->rank >= 2)
            vpi_printf("%d: a1 %s, attempt started at %d\n", e->when, what, e->start);
        else
            vpi_printf("%d: a1 %s, attempt information %s\n", e->when, what,
                       e->info_null ? "NULL" : "given");
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
    add_task("$vt_reset", reset_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
