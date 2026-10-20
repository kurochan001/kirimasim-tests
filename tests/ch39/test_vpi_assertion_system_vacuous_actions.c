/* VPI application of test_vpi_assertion_system_vacuous_actions (IEEE 1800-2023 39.5.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 16

struct event {
    int when;
    int order;
    const char *text;
};

static struct event events[MAX];
static int n_events;

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_system(p_cb_data data)
{
    if (n_events == MAX)
        return 0;
    events[n_events].when = now();
    events[n_events].order = n_events;
    events[n_events].text = (const char *)data->user_data;
    n_events++;
    return 0;
}

static void system_cb(PLI_INT32 reason, const char *text)
{
    static s_vpi_time suppress;
    s_cb_data d;
    memset(&d, 0, sizeof d);
    suppress.type = vpiSuppressTime;
    d.reason = reason;
    d.cb_rtn = on_system;
    d.time = &suppress;
    d.user_data = (PLI_BYTE8 *)text;
    if (vpi_register_cb(&d) == NULL)
        vpi_printf("system callback for %s not placed\n", text);
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    system_cb(cbAssertionSysDisableVacuousAction, "vacuous pass action disabled");
    system_cb(cbAssertionSysEnablePassAction, "pass action enabled");
    system_cb(cbAssertionSysDisablePassAction, "pass action disabled");
    system_cb(cbAssertionSysEnableNonvacuousAction, "nonvacuous pass action enabled");
    return 0;
}

static PLI_INT32 control_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    (void)user_data;
    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    if (strcmp(v.value.str, "disable vacuous") == 0)
        vpi_control(vpiAssertionSysDisableVacuousAction, NULL);
    else if (strcmp(v.value.str, "enable pass") == 0)
        vpi_control(vpiAssertionSysEnablePassAction, NULL);
    else if (strcmp(v.value.str, "disable pass") == 0)
        vpi_control(vpiAssertionSysDisablePassAction, NULL);
    else if (strcmp(v.value.str, "enable nonvacuous") == 0)
        vpi_control(vpiAssertionSysEnableNonvacuousAction, NULL);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct event *a = (const struct event *)pa, *b = (const struct event *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    return a->order - b->order;
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
