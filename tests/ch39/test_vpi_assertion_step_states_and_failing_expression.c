/* VPI application of test_vpi_assertion_step_states_and_failing_expression (IEEE 1800-2023 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_step_states_and_failing_expression"
#define MAX 64

struct step {
    int when, start, failing, from, to, has_info;
    char last[32];
};

static struct step steps[MAX];
static int n_steps;
static vpiHandle a1;

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)t->real;
    return (int)t->low;
}

/* The name of an expression, or its source text when it has no name. */
static void expression_text(vpiHandle expr, char *buf, size_t size)
{
    PLI_BYTE8 *s = NULL;

    if (expr != NULL) {
        s = vpi_get_str(vpiName, expr);
        if (s == NULL)
            s = vpi_get_str(vpiDecompile, expr);
    }
    snprintf(buf, size, "%s", s != NULL ? s : "none");
}

static PLI_INT32 on_step(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                         p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    struct step *s;
    p_vpi_assertion_step_info d;

    (void)assertion;
    (void)user_data;
    if (n_steps >= MAX)
        return 0;
    s = &steps[n_steps++];
    memset(s, 0, sizeof *s);
    s->when = ticks(cb_time);
    s->failing = reason == cbAssertionStepFailure;
    d = info != NULL ? info->detail.step : NULL;
    s->has_info = d != NULL;
    s->start = info != NULL ? ticks(&info->attemptStartTime) : -1;
    if (d != NULL) {
        s->from = d->stateFrom;
        s->to = d->stateTo;
        if (d->matched_expression_count > 0 && d->matched_exprs != NULL)
            expression_text(d->matched_exprs[d->matched_expression_count - 1], s->last,
                            sizeof s->last);
        else
            snprintf(s->last, sizeof s->last, "none");
    }
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    static const int starts[] = {15, 45};
    s_vpi_time t;
    int i;

    (void)user_data;
    a1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a1", NULL);
    if (a1 == NULL) {
        vpi_printf((PLI_BYTE8 *)"a1 not found\n");
        return 0;
    }
    if (vpi_register_assertion_cb(a1, cbAssertionStepSuccess, on_step, NULL) == NULL)
        vpi_printf((PLI_BYTE8 *)"a1: step callback not placed\n");
    for (i = 0; i < 2; i++) {
        memset(&t, 0, sizeof t);
        t.type = vpiSimTime;
        t.low = (PLI_UINT32)starts[i];
        vpi_control(vpiAssertionEnableStep, a1, &t, vpiAssertionClockSteps);
    }
    return 0;
}

static const char *state(int id)
{
    return id == 0 ? "origin" : id == 1 ? "accepting" : "intermediate";
}

static int by_time(const void *pa, const void *pb)
{
    const struct step *a = (const struct step *)pa;
    const struct step *b = (const struct step *)pb;
    if (a->start != b->start)
        return a->start - b->start;
    if (a->when != b->when)
        return a->when - b->when;
    return a->failing - b->failing;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    char line[160], previous[160] = "";
    int i;

    (void)user_data;
    qsort(steps, n_steps, sizeof steps[0], by_time);
    for (i = 0; i < n_steps; i++) {
        const struct step *s = &steps[i];
        if (!s->has_info)
            snprintf(line, sizeof line, "attempt %d, %d: step without step information",
                     s->start, s->when);
        else if (s->failing)
            snprintf(line, sizeof line, "attempt %d, %d: failing step from %s, last expression %s",
                     s->start, s->when, state(s->from), s->last);
        else
            snprintf(line, sizeof line, "attempt %d, %d: step from %s to %s, last expression %s",
                     s->start, s->when, state(s->from), state(s->to), s->last);
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
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
