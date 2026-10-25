/* VPI application of test_assertcontrol_callbacks_selected (IEEE 1800-2023 20.11, 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_assertcontrol_callbacks_selected"
#define MAX 128

struct pair {
    const char *name;
    PLI_INT32 code;
};

static const struct pair reasons[] = {
    {"lock", cbAssertionLock},
    {"unlock", cbAssertionUnlock},
    {"enable", cbAssertionEnable},
    {"disable", cbAssertionDisable},
    {"reset", cbAssertionReset},
    {"kill", cbAssertionKill},
    {"enable pass action", cbAssertionEnablePassAction},
    {"disable pass action", cbAssertionDisablePassAction},
    {"enable fail action", cbAssertionEnableFailAction},
    {"disable fail action", cbAssertionDisableFailAction},
    {"enable nonvacuous action", cbAssertionEnableNonvacuousAction},
    {"disable vacuous action", cbAssertionDisableVacuousAction},
};

#define COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

struct event {
    int when;
    int which;
    int reason;
};

static struct event events[MAX];
static int n_events, mismatches, printing;
static vpiHandle watched[2];
static const char *const names[2] = {"a1", "a2"};

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)(t->real + 0.5);
    return (int)t->low;
}

static int reason_index(PLI_INT32 code)
{
    int i;

    for (i = 0; i < COUNT(reasons); i++)
        if (reasons[i].code == code)
            return i;
    return -1;
}

static PLI_INT32 on_assertion(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                              p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    struct event *e;
    int which = -1, i, r;

    (void)info;
    (void)user_data;
    for (i = 0; i < 2; i++)
        if (watched[i] != NULL && vpi_compare_objects(assertion, watched[i]))
            which = i;
    if (which < 0) {
        mismatches++;
        return 0;
    }
    if (!printing || n_events == MAX)
        return 0;
    r = reason_index(reason);
    if (r < 0) {
        mismatches++;
        return 0;
    }
    e = &events[n_events++];
    e->when = ticks(cb_time);
    e->which = which;
    e->reason = r;
    return 0;
}

static int by_event(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa, *b = (const struct event *)pb;

    if (a->when != b->when)
        return a->when - b->when;
    if (a->which != b->which)
        return a->which - b->which;
    return strcmp(reasons[a->reason].name, reasons[b->reason].name);
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    char full[64];
    int i, j;

    (void)user_data;
    for (i = 0; i < 2; i++) {
        snprintf(full, sizeof full, "%s.%s", TOP, names[i]);
        watched[i] = vpi_handle_by_name(full, NULL);
        if (watched[i] == NULL) {
            vpi_printf("%s not found\n", full);
            continue;
        }
        for (j = 0; j < COUNT(reasons); j++)
            if (vpi_register_assertion_cb(watched[i], reasons[j].code, on_assertion,
                                          NULL) == NULL)
                vpi_printf("%s: callback %s not placed\n", names[i], reasons[j].name);
    }
    return 0;
}

static PLI_INT32 begin_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    printing = 1;
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    qsort(events, n_events, sizeof events[0], by_event);
    for (i = 0; i < n_events; i++)
        vpi_printf("%d: %s %s\n", events[i].when, names[events[i].which],
                   reasons[events[i].reason].name);
    vpi_printf("callbacks with a wrong handle or reason: %d\n", mismatches);
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
    add_task("$vt_begin", begin_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
