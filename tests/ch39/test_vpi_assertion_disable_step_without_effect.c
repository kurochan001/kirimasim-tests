/* VPI application of test_vpi_assertion_disable_step_without_effect (IEEE 1800-2023 39.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_disable_step_without_effect"
#define MAX 64

struct record {
    int when, start;
};

static struct record successes[MAX], steps[MAX];
static int n_successes, n_steps;
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
    if (reason == cbAssertionSuccess)
        add(successes, &n_successes, cb_time, info);
    else if (reason == cbAssertionStepSuccess || reason == cbAssertionStepFailure)
        add(steps, &n_steps, cb_time, info);
    return 0;
}

static void attempt_time(s_vpi_time *t, int start)
{
    memset(t, 0, sizeof *t);
    t->type = vpiSimTime;
    t->high = 0;
    t->low = (PLI_UINT32)start;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_time t;

    (void)user_data;
    a1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a1", NULL);
    if (a1 == NULL) {
        vpi_printf((PLI_BYTE8 *)"a1 not found\n");
        return 0;
    }
    if (vpi_register_assertion_cb(a1, cbAssertionStepSuccess, on_assertion, NULL) == NULL)
        vpi_printf((PLI_BYTE8 *)"a1: step callback not placed\n");
    if (vpi_register_assertion_cb(a1, cbAssertionSuccess, on_assertion, NULL) == NULL)
        vpi_printf((PLI_BYTE8 *)"a1: success callback not placed\n");
    attempt_time(&t, 15);
    vpi_control(vpiAssertionEnableStep, a1, &t, vpiAssertionClockSteps);
    return 0;
}

static PLI_INT32 step_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle op_arg = it ? vpi_scan(it) : NULL;
    vpiHandle time_arg = op_arg ? vpi_scan(it) : NULL;
    s_vpi_value op, start;
    s_vpi_time t;

    (void)user_data;
    if (time_arg == NULL || a1 == NULL) {
        vpi_printf((PLI_BYTE8 *)"$vt_step: two arguments and a1 needed\n");
        return 0;
    }
    vpi_release_handle(it);
    start.format = vpiIntVal;
    vpi_get_value(time_arg, &start);
    attempt_time(&t, (int)start.value.integer);
    op.format = vpiStringVal;
    vpi_get_value(op_arg, &op);
    if (strcmp(op.value.str, "enable") == 0)
        vpi_control(vpiAssertionEnableStep, a1, &t, vpiAssertionClockSteps);
    else if (strcmp(op.value.str, "disable") == 0)
        vpi_control(vpiAssertionDisableStep, a1, &t);
    else
        vpi_printf((PLI_BYTE8 *)"$vt_step: unknown operation %s\n", op.value.str);
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
    int i;

    (void)user_data;
    qsort(steps, n_steps, sizeof steps[0], by_time);
    qsort(successes, n_successes, sizeof successes[0], by_time);
    for (i = 0; i < n_steps; i++)
        if (i == 0 || steps[i].when != steps[i - 1].when || steps[i].start != steps[i - 1].start)
            vpi_printf((PLI_BYTE8 *)"%d: a1 step, attempt started at %d\n", steps[i].when,
                       steps[i].start);
    for (i = 0; i < n_successes; i++)
        vpi_printf((PLI_BYTE8 *)"%d: a1 success, attempt started at %d\n", successes[i].when,
                   successes[i].start);
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
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
