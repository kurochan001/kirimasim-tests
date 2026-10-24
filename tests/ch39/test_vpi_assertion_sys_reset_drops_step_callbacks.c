/* VPI application of test_vpi_assertion_sys_reset_drops_step_callbacks (IEEE 1800-2023 39.5.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_sys_reset_drops_step_callbacks"
#define MAX 64

struct record {
    int when, start;
};

static struct record starts[MAX], successes[MAX], steps[MAX];
static int n_starts, n_successes, n_steps, reset_at = -1;
static vpiHandle a1;

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)t->real;
    return (int)t->low;
}

static void add(struct record *list, int *n, p_vpi_time cb_time, p_vpi_attempt_info info)
{
    if (*n >= MAX)
        return;
    list[*n].when = ticks(cb_time);
    list[*n].start = info != NULL ? ticks(&info->attemptStartTime) : -1;
    (*n)++;
}

static PLI_INT32 on_assertion(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                              p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    (void)assertion;
    (void)user_data;
    if (reason == cbAssertionStart)
        add(starts, &n_starts, cb_time, info);
    else if (reason == cbAssertionSuccess)
        add(successes, &n_successes, cb_time, info);
    else if (reason == cbAssertionStepSuccess || reason == cbAssertionStepFailure)
        add(steps, &n_steps, cb_time, info);
    return 0;
}

static void enable_step(int start)
{
    s_vpi_time t;

    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    t.high = 0;
    t.low = (PLI_UINT32)start;
    vpi_control(vpiAssertionEnableStep, a1, &t, vpiAssertionClockSteps);
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    static const PLI_INT32 reasons[] = {cbAssertionStart, cbAssertionSuccess,
                                        cbAssertionStepSuccess};
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
    enable_step(5);
    return 0;
}

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 reset_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    reset_at = now();
    vpi_control(vpiAssertionSysReset, (vpiHandle)NULL);
    return 0;
}

static PLI_INT32 step_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    (void)user_data;
    if (arg == NULL || a1 == NULL) {
        vpi_printf((PLI_BYTE8 *)"$vt_step: no argument or no assertion\n");
        return 0;
    }
    vpi_release_handle(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    enable_step((int)v.value.integer);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct record *a = (const struct record *)pa;
    const struct record *b = (const struct record *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    return a->start - b->start;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i, late = 0;

    (void)user_data;
    qsort(starts, n_starts, sizeof starts[0], by_time);
    qsort(successes, n_successes, sizeof successes[0], by_time);
    qsort(steps, n_steps, sizeof steps[0], by_time);
    vpi_printf((PLI_BYTE8 *)"a1 attempts started at:");
    for (i = 0; i < n_starts; i++)
        vpi_printf((PLI_BYTE8 *)" %d", starts[i].when);
    vpi_printf((PLI_BYTE8 *)"\n");
    for (i = 0; i < n_successes; i++)
        vpi_printf((PLI_BYTE8 *)"%d: a1 success, attempt started at %d\n", successes[i].when,
                   successes[i].start);
    for (i = 0; i < n_steps; i++)
        if (i == 0 || steps[i].when != steps[i - 1].when || steps[i].start != steps[i - 1].start)
            vpi_printf((PLI_BYTE8 *)"%d: a1 step, attempt started at %d\n", steps[i].when,
                       steps[i].start);
    for (i = 0; i < n_steps; i++)
        if (steps[i].when > reset_at)
            late++;
    vpi_printf((PLI_BYTE8 *)"step callbacks after the reset at %d: %d\n", reset_at, late);
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
    add_task("$vt_reset", reset_calltf);
    add_task("$vt_step", step_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
