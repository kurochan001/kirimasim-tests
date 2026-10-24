/* VPI application of test_vpi_assertion_callback_time_and_attempt_info (IEEE 1800-2023 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_callback_time_and_attempt_info"
#define MAX 64

struct kind {
    PLI_INT32 reason;
    const char *name;
    int which;        /* 0: placed on a1, 1: placed on a2 */
    int with_start;   /* the callback gets the attempt start time */
};

/* In the order in which the events of one time step are printed. */
static const struct kind kinds[] = {
    {cbAssertionStart, "start", 0, 1},
    {cbAssertionSuccess, "success", 0, 1},
    {cbAssertionFailure, "failure", 0, 1},
    {cbAssertionStepSuccess, "step success", 0, 1},
    {cbAssertionStepFailure, "step failure", 0, 1},
    {cbAssertionKill, "kill", 0, 0},
    {cbAssertionReset, "reset", 0, 0},
    {cbAssertionDisable, "disable", 0, 0},
    {cbAssertionEnable, "enable", 0, 0},
    {cbAssertionVacuousSuccess, "vacuous success", 1, 0},
    {cbAssertionDisabledEvaluation, "disabled evaluation", 1, 0},
};

#define COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

struct event {
    int which, when, rank, start, info, fail_expr, step;
};

static struct event events[MAX];
static int n_events;
static vpiHandle handles[2];
static const char *const tags[2] = {"a1", "a2"};

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)t->real;
    return (int)t->low;
}

static PLI_INT32 on_assertion(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                              p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    struct event *e;
    int i, rank = -1;

    (void)assertion;
    for (i = 0; i < COUNT(kinds); i++)
        if (kinds[i].reason == reason)
            rank = i;
    if (rank < 0 || n_events >= MAX)
        return 0;
    e = &events[n_events++];
    e->which = user_data == (PLI_BYTE8 *)tags[1] ? 1 : 0;
    e->when = ticks(cb_time);
    e->rank = rank;
    e->info = info != NULL;
    e->start = info != NULL && kinds[rank].with_start ? ticks(&info->attemptStartTime) : -1;
    e->fail_expr = reason == cbAssertionFailure && info != NULL && info->detail.failExpr != NULL;
    e->step = (reason == cbAssertionStepSuccess || reason == cbAssertionStepFailure)
              && info != NULL && info->detail.step != NULL;
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    char full[128];
    int i;

    (void)user_data;
    for (i = 0; i < 2; i++) {
        snprintf(full, sizeof full, "%s.%s", TOP, tags[i]);
        handles[i] = vpi_handle_by_name(full, NULL);
        if (handles[i] == NULL)
            vpi_printf((PLI_BYTE8 *)"%s not found\n", full);
    }
    for (i = 0; i < COUNT(kinds); i++) {
        vpiHandle h = handles[kinds[i].which];
        /* Only cbAssertionStepFailure is placed: it is also called for the steps that succeed. */
        if (h == NULL || kinds[i].reason == cbAssertionStepSuccess)
            continue;
        if (vpi_register_assertion_cb(h, kinds[i].reason, on_assertion,
                                      (PLI_BYTE8 *)tags[kinds[i].which]) == NULL)
            vpi_printf((PLI_BYTE8 *)"%s: %s callback not placed\n", tags[kinds[i].which],
                       kinds[i].name);
    }
    return 0;
}

static int int_argument(void)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    if (arg == NULL)
        return -1;
    vpi_release_handle(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    return (int)v.value.integer;
}

static void attempt_time(s_vpi_time *t, int start)
{
    memset(t, 0, sizeof *t);
    t->type = vpiSimTime;
    t->high = 0;
    t->low = (PLI_UINT32)start;
}

static PLI_INT32 step_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_time t;

    (void)user_data;
    attempt_time(&t, int_argument());
    if (handles[0] != NULL)
        vpi_control(vpiAssertionEnableStep, handles[0], &t, vpiAssertionClockSteps);
    return 0;
}

static PLI_INT32 kill_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_time t;

    (void)user_data;
    attempt_time(&t, int_argument());
    if (handles[0] != NULL)
        vpi_control(vpiAssertionKill, handles[0], &t);
    return 0;
}

static PLI_INT32 control_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;
    PLI_INT32 op = 0;

    (void)user_data;
    if (arg == NULL || handles[0] == NULL) {
        vpi_printf((PLI_BYTE8 *)"$vt_control: no argument or no assertion\n");
        return 0;
    }
    vpi_release_handle(it);
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    if (strcmp(v.value.str, "reset") == 0)
        op = vpiAssertionReset;
    else if (strcmp(v.value.str, "disable") == 0)
        op = vpiAssertionDisable;
    else if (strcmp(v.value.str, "enable") == 0)
        op = vpiAssertionEnable;
    if (op == 0)
        vpi_printf((PLI_BYTE8 *)"$vt_control: unknown control %s\n", v.value.str);
    else
        vpi_control(op, handles[0]);
    return 0;
}

static int by_order(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa;
    const struct event *b = (const struct event *)pb;
    if (a->which != b->which)
        return a->which - b->which;
    if (a->when != b->when)
        return a->when - b->when;
    if (a->rank != b->rank)
        return a->rank - b->rank;
    return a->start - b->start;
}

static void format(const struct event *e, char *buf, size_t size)
{
    const struct kind *k = &kinds[e->rank];
    int n = snprintf(buf, size, "%d: %s %s", e->when, tags[e->which], k->name);

    if (k->with_start) {
        if (e->info)
            n += snprintf(buf + n, size - n, ", attempt started at %d", e->start);
        else
            n += snprintf(buf + n, size - n, ", no attempt information");
    }
    if (k->reason == cbAssertionFailure)
        snprintf(buf + n, size - n, ", failing expression %s", e->fail_expr ? "given" : "missing");
    else if (k->reason == cbAssertionStepSuccess || k->reason == cbAssertionStepFailure)
        snprintf(buf + n, size - n, ", step information %s", e->step ? "given" : "missing");
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    char line[160], previous[160] = "";
    int i;

    (void)user_data;
    qsort(events, n_events, sizeof events[0], by_order);
    for (i = 0; i < n_events; i++) {
        format(&events[i], line, sizeof line);
        if (strcmp(line, previous) != 0)
            vpi_printf((PLI_BYTE8 *)"%s\n", line);
        strcpy(previous, line);
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
    add_task("$vt_step", step_calltf);
    add_task("$vt_kill", kill_calltf);
    add_task("$vt_control", control_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
