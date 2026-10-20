/* VPI application of test_vpi_assertion_step_callbacks (IEEE 1800-2023 39.5.2, 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 64

struct step {
    int when;
    int failure;
    int start;
    int count;
    int from;
};

static struct step steps[MAX];
static int n_steps;
static vpiHandle a1;

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)(t->real + 0.5);
    return (int)t->low;
}

static PLI_INT32 on_step(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                         p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    struct step *s;

    (void)assertion;
    (void)user_data;
    if (n_steps == MAX)
        return 0;
    s = &steps[n_steps++];
    s->when = ticks(cb_time);
    s->failure = reason == cbAssertionStepFailure;
    s->start = info != NULL ? ticks(&info->attemptStartTime) : -1;
    s->count = info != NULL && info->detail.step != NULL
               ? info->detail.step->matched_expression_count : -1;
    s->from = info != NULL && info->detail.step != NULL ? info->detail.step->stateFrom : -1;
    return 0;
}

static s_vpi_time at(int t)
{
    s_vpi_time v;
    v.type = vpiSimTime;
    v.high = 0;
    v.low = (PLI_UINT32)t;
    v.real = 0.0;
    return v;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_time t15 = at(15), t45 = at(45);

    (void)user_data;
    a1 = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_assertion_step_callbacks.a1", NULL);
    if (a1 == NULL) {
        vpi_printf("a1 not found\n");
        return 0;
    }
    vpi_printf("step callback %s\n",
               vpi_register_assertion_cb(a1, cbAssertionStepSuccess, on_step, NULL) != NULL
               ? "placed" : "not placed");
    vpi_control(vpiAssertionEnableStep, a1, &t15, vpiAssertionClockSteps);
    vpi_control(vpiAssertionEnableStep, a1, &t45, vpiAssertionClockSteps);
    return 0;
}

static PLI_INT32 nostep_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_time t45 = at(45);

    (void)user_data;
    if (a1 != NULL)
        vpi_control(vpiAssertionDisableStep, a1, &t45);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct step *a = (const struct step *)pa, *b = (const struct step *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    return a->failure - b->failure;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i, others = 0, failing_ok = 1, failing = 0, from_origin = 0;

    (void)user_data;
    qsort(steps, n_steps, sizeof steps[0], by_time);
    for (i = 0; i < n_steps; i++)
        if (steps[i].start != 15)
            others++;
    vpi_printf("steps of other attempts: %d\n", others);
    for (i = 0; i < n_steps; i++) {
        const struct step *s = &steps[i];
        if (s->start != 15)
            continue;
        if (s->when == 15 && s->from == 0)
            from_origin = 1;
        if (s->failure) {
            failing = 1;
            if (s->count < 1)
                failing_ok = 0;
        }
        if (i > 0 && steps[i - 1].start == 15 && steps[i - 1].when == s->when
            && steps[i - 1].failure == s->failure)
            continue;
        vpi_printf("%d: step %s\n", s->when, s->failure ? "failure" : "success");
    }
    if (failing)
        vpi_printf("failing step has an expression: %s\n", failing_ok ? "yes" : "no");
    vpi_printf("a step at the start leaves state 0: %s\n", from_origin ? "yes" : "no");
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
    add_task("$vt_nostep", nostep_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
