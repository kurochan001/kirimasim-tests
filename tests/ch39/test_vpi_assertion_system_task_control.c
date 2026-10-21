/* VPI application of test_vpi_assertion_system_task_control (IEEE 1800-2023 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 32

/* ranks order the callbacks of one time step: an attempt starts before it
   succeeds or fails, and the attempt start time orders the two attempts. */
struct event {
    int when;
    int rank;
    int start;
};

static struct event events[MAX];
static int n_events;

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
    e->start = info != NULL ? ticks(&info->attemptStartTime) : -1;
    switch (reason) {
    case cbAssertionStart: e->rank = 0; break;
    case cbAssertionSuccess: e->rank = 1; break;
    case cbAssertionFailure: e->rank = 2; break;
    case cbAssertionDisable: e->rank = 3; break;
    case cbAssertionEnable: e->rank = 4; break;
    case cbAssertionKill: e->rank = 5; break;
    default: e->rank = 6; break;
    }
    return 0;
}

static vpiHandle find_assertion(const char *name)
{
    vpiHandle it = vpi_iterate(vpiAssertion, NULL), h;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *n = vpi_get_str(vpiName, h);
        if (n != NULL && strcmp(n, name) == 0)
            return h;
    }
    return NULL;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    static const PLI_INT32 cbs[] = {cbAssertionStart, cbAssertionSuccess, cbAssertionFailure,
                                    cbAssertionDisable, cbAssertionEnable, cbAssertionKill};
    vpiHandle a = find_assertion("a1");
    size_t i;

    (void)user_data;
    if (a == NULL) {
        vpi_printf("assertion a1: not found\n");
        return 0;
    }
    for (i = 0; i < sizeof cbs / sizeof cbs[0]; i++)
        if (vpi_register_assertion_cb(a, cbs[i], on_assertion, NULL) == NULL)
            vpi_printf("callback %d: not placed\n", (int)cbs[i]);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa, *b = (const struct event *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    if (a->start != b->start)
        return a->start < b->start ? -1 : 1;
    return a->rank - b->rank;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    static const char *const names[] = {"start", "success", "failure",
                                        "disable", "enable", "kill", "other reason"};
    int i;

    (void)user_data;
    qsort(events, n_events, sizeof events[0], by_time);
    for (i = 0; i < n_events; i++) {
        const struct event *e = &events[i];
        if (e->rank <= 2)
            vpi_printf("%d: a1 %s, attempt started at %d\n", e->when, names[e->rank], e->start);
        else
            vpi_printf("%d: a1 %s, attempt information %s\n", e->when, names[e->rank],
                       e->start < 0 ? "NULL" : "given");
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
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
