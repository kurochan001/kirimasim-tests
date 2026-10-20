/* VPI application of test_vpi_assertion_system_lock_reset (IEEE 1800-2023 39.5.1). */
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
    char text[64];
};

static struct event events[MAX];
static int n_events;
static vpiHandle a1;

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)(t->real + 0.5);
    return (int)t->low;
}

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static void record(int when, const char *text)
{
    if (n_events == MAX)
        return;
    events[n_events].when = when;
    snprintf(events[n_events].text, sizeof events[0].text, "%s", text);
    n_events++;
}

static PLI_INT32 on_system(p_cb_data data)
{
    record(now(), data->reason == cbAssertionSysLock ? "system locked"
           : data->reason == cbAssertionSysUnlock ? "system unlocked"
           : data->reason == cbAssertionSysReset ? "system reset" : "other system reason");
    return 0;
}

static PLI_INT32 on_assertion(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                              p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    char text[64];

    (void)assertion;
    (void)user_data;
    snprintf(text, sizeof text, "a1 %s, attempt started at %d",
             reason == cbAssertionSuccess ? "success" : "failure",
             info != NULL ? ticks(&info->attemptStartTime) : -1);
    record(ticks(cb_time), text);
    return 0;
}

static void system_cb(PLI_INT32 reason)
{
    static s_vpi_time suppress;
    s_cb_data d;
    memset(&d, 0, sizeof d);
    suppress.type = vpiSuppressTime;
    d.reason = reason;
    d.cb_rtn = on_system;
    d.time = &suppress;
    if (vpi_register_cb(&d) == NULL)
        vpi_printf("system callback %d not placed\n", (int)reason);
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    system_cb(cbAssertionSysLock);
    system_cb(cbAssertionSysUnlock);
    system_cb(cbAssertionSysReset);
    a1 = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_assertion_system_lock_reset.a1", NULL);
    if (a1 == NULL) {
        vpi_printf("a1 not found\n");
        return 0;
    }
    if (vpi_register_assertion_cb(a1, cbAssertionSuccess, on_assertion, NULL) == NULL ||
        vpi_register_assertion_cb(a1, cbAssertionFailure, on_assertion, NULL) == NULL)
        vpi_printf("assertion callback not placed\n");
    return 0;
}

static PLI_INT32 control_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    (void)user_data;
    if (arg == NULL || a1 == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    if (strcmp(v.value.str, "lock") == 0)
        vpi_control(vpiAssertionSysLock, NULL);
    else if (strcmp(v.value.str, "unlock") == 0)
        vpi_control(vpiAssertionSysUnlock, NULL);
    else if (strcmp(v.value.str, "reset") == 0)
        vpi_control(vpiAssertionSysReset, NULL);
    else if (strcmp(v.value.str, "disable") == 0)
        vpi_control(vpiAssertionDisable, a1);
    else if (strcmp(v.value.str, "enable") == 0)
        vpi_control(vpiAssertionEnable, a1);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa, *b = (const struct event *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    return strcmp(a->text, b->text);
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    qsort(events, n_events, sizeof events[0], by_time);
    for (i = 0; i < n_events; i++)
        vpi_printf("%d: %s\n", events[i].when, events[i].text);
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
    add_task("$vt_control", control_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
