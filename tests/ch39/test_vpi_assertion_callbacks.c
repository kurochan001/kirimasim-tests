/* VPI application of test_vpi_assertion_callbacks (IEEE 1800-2023 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_callbacks"
#define MAX 64

struct event {
    int when;
    int name;
    int rank;
    int start;
};

static struct event events[MAX];
static int n_events, mismatches;
static vpiHandle watched[3];
static const char *const names[3] = {"a1", "a2", "a3"};

static const char *const reasons[] = {
    "start", "success", "vacuous success", "failure", "disabled evaluation"
};

static int rank_of(PLI_INT32 reason)
{
    switch (reason) {
    case cbAssertionStart: return 0;
    case cbAssertionSuccess: return 1;
    case cbAssertionVacuousSuccess: return 2;
    case cbAssertionFailure: return 3;
    case cbAssertionDisabledEvaluation: return 4;
    default: return -1;
    }
}

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
    int which = (int)(user_data - (PLI_BYTE8 *)names);
    struct event *e;

    if (which < 0 || which > 2 || !vpi_compare_objects(assertion, watched[which]))
        mismatches++;
    if (n_events == MAX || which < 0 || which > 2)
        return 0;
    e = &events[n_events++];
    e->when = ticks(cb_time);
    e->name = which;
    e->rank = rank_of(reason);
    /* attemptStartTime is given for start, success and failure (39.4.2). */
    if ((reason == cbAssertionStart || reason == cbAssertionSuccess
         || reason == cbAssertionFailure) && info != NULL)
        e->start = ticks(&info->attemptStartTime);
    else
        e->start = -1;
    return 0;
}

static void place(int which, PLI_INT32 reason)
{
    if (vpi_register_assertion_cb(watched[which], reason, on_assertion,
                                  (PLI_BYTE8 *)names + which) == NULL)
        vpi_printf("%s: callback not placed\n", names[which]);
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    char full[64];
    int i;

    (void)user_data;
    for (i = 0; i < 3; i++) {
        snprintf(full, sizeof full, "%s.%s", TOP, names[i]);
        watched[i] = vpi_handle_by_name(full, NULL);
        if (watched[i] == NULL) {
            vpi_printf("%s not found\n", full);
            return 0;
        }
    }
    place(0, cbAssertionStart);
    place(0, cbAssertionSuccess);
    place(0, cbAssertionFailure);
    place(1, cbAssertionSuccess);
    place(1, cbAssertionVacuousSuccess);
    place(1, cbAssertionFailure);
    place(2, cbAssertionDisabledEvaluation);
    place(2, cbAssertionSuccess);
    place(2, cbAssertionVacuousSuccess);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa, *b = (const struct event *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    if (a->name != b->name)
        return a->name - b->name;
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
        if (e->start >= 0)
            vpi_printf("%d: %s %s, attempt started at %d\n", e->when, names[e->name], what,
                       e->start);
        else
            vpi_printf("%d: %s %s\n", e->when, names[e->name], what);
    }
    vpi_printf("callbacks with a wrong handle or user data: %d\n", mismatches);
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
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
