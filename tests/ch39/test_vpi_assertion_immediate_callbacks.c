/* VPI application of test_vpi_assertion_immediate_callbacks (IEEE 1800-2023 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 64

struct event {
    int when;
    int kind;        /* 0 assert, 1 assume, 2 cover */
    int rank;        /* 0 start, 1 success, 2 failure */
    int start;
    int fail_expr;
};

static const char *const kinds[] = {"assert", "assume", "cover"};
static const char *const reasons[] = {"start", "success", "failure"};

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
    if (n_events == MAX)
        return 0;
    e = &events[n_events++];
    e->when = ticks(cb_time);
    e->kind = (int)(*user_data - '0');
    e->rank = reason == cbAssertionStart ? 0 : reason == cbAssertionSuccess ? 1
              : reason == cbAssertionFailure ? 2 : -1;
    e->start = info != NULL ? ticks(&info->attemptStartTime) : -1;
    e->fail_expr = reason == cbAssertionFailure && info != NULL && info->detail.failExpr != NULL;
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    static PLI_BYTE8 tags[3][2] = {"0", "1", "2"};
    static const PLI_INT32 cbs[] = {cbAssertionStart, cbAssertionSuccess, cbAssertionFailure};
    vpiHandle it, a;
    int found = 0, i;

    (void)user_data;
    it = vpi_iterate(vpiAssertion, NULL);
    while (it != NULL && (a = vpi_scan(it)) != NULL) {
        PLI_INT32 type = vpi_get(vpiType, a);
        int kind = type == vpiImmediateAssert ? 0 : type == vpiImmediateAssume ? 1
                   : type == vpiImmediateCover ? 2 : -1;
        if (kind < 0)
            continue;
        found++;
        /* A cover that does not match has no failure, so its failure
           callback is not placed. */
        for (i = 0; i < (kind == 2 ? 2 : 3); i++)
            if (vpi_register_assertion_cb(a, cbs[i], on_assertion, tags[kind]) == NULL)
                vpi_printf("%s: callback %d not placed\n", kinds[kind], (int)cbs[i]);
    }
    vpi_printf("immediate assertions found: %d\n", found);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa, *b = (const struct event *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    if (a->kind != b->kind)
        return a->kind - b->kind;
    return a->rank - b->rank;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    qsort(events, n_events, sizeof events[0], by_time);
    for (i = 0; i < n_events; i++) {
        const struct event *e = &events[i];
        if (e->rank < 0) {
            vpi_printf("%d: %s other reason\n", e->when, kinds[e->kind]);
            continue;
        }
        vpi_printf("%d: %s %s, attempt started at %d%s\n", e->when, kinds[e->kind],
                   reasons[e->rank], e->start,
                   e->rank == 2 ? (e->fail_expr ? ", failing expression given"
                                                : ", no failing expression") : "");
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
