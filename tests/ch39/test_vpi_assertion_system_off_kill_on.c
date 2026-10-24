/* VPI application of test_vpi_assertion_system_off_kill_on (IEEE 1800-2023 39.5.1, 39.4.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_system_off_kill_on"
#define MAX 32

struct pair {
    const char *name;
    PLI_INT32 code;
};

static const struct pair controls[] = {
    {"off", vpiAssertionSysOff},
    {"kill", vpiAssertionSysKill},
    {"on", vpiAssertionSysOn},
};

static const struct pair reasons[] = {
    {"off", cbAssertionSysOff},
    {"kill", cbAssertionSysKill},
    {"on", cbAssertionSysOn},
};

#define COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

struct sys_event {
    int when;
    const char *what;
};

static struct sys_event sys_events[MAX];
static int n_sys, controlled;
static char tags[2][5] = {"a1", "u.a2"};
static int starts[2][MAX], n_starts[2];

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_system(p_cb_data cb)
{
    if (controlled && n_sys < MAX) {
        sys_events[n_sys].when = now();
        sys_events[n_sys].what = cb->user_data;
        n_sys++;
    }
    return 0;
}

static PLI_INT32 on_start(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                          p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    int which = user_data == tags[1] ? 1 : 0;

    (void)cb_time;
    (void)assertion;
    (void)info;
    if (reason == cbAssertionStart && n_starts[which] < MAX)
        starts[which][n_starts[which]++] = now();
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    char full[64];
    vpiHandle h;
    s_cb_data cb;
    int i;

    (void)user_data;
    for (i = 0; i < 2; i++) {
        snprintf(full, sizeof full, "%s.%s", TOP, tags[i]);
        h = vpi_handle_by_name(full, NULL);
        if (h == NULL)
            vpi_printf("%s not found\n", full);
        else if (vpi_register_assertion_cb(h, cbAssertionStart, on_start, tags[i]) == NULL)
            vpi_printf("%s: start callback not placed\n", tags[i]);
    }
    /* Not from vlog_startup_routines, which may place only the reasons of 36.10.2. */
    for (i = 0; i < COUNT(reasons); i++) {
        memset(&cb, 0, sizeof cb);
        cb.reason = reasons[i].code;
        cb.cb_rtn = on_system;
        cb.user_data = (PLI_BYTE8 *)reasons[i].name;
        if (vpi_register_cb(&cb) == NULL)
            vpi_printf("%s: system callback not placed\n", reasons[i].name);
    }
    return 0;
}

static PLI_INT32 system_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;
    int i;

    (void)user_data;
    if (arg == NULL) {
        vpi_printf("$vt_system: no argument\n");
        return 0;
    }
    vpi_release_handle(it);
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    controlled = 1;
    for (i = 0; i < COUNT(controls); i++)
        if (strcmp(v.value.str, controls[i].name) == 0) {
            vpi_control(controls[i].code, NULL);
            return 0;
        }
    vpi_printf("$vt_system: unknown control %s\n", v.value.str);
    return 0;
}

static int by_time(const void *pa, const void *pb)
{
    const struct sys_event *a = (const struct sys_event *)pa;
    const struct sys_event *b = (const struct sys_event *)pb;
    if (a->when != b->when)
        return a->when - b->when;
    return strcmp(a->what, b->what);
}

static int by_value(const void *pa, const void *pb)
{
    return *(const int *)pa - *(const int *)pb;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i, j;

    (void)user_data;
    qsort(sys_events, n_sys, sizeof sys_events[0], by_time);
    for (i = 0; i < n_sys; i++)
        vpi_printf("%d: system callback: %s\n", sys_events[i].when, sys_events[i].what);
    for (i = 0; i < 2; i++) {
        qsort(starts[i], n_starts[i], sizeof starts[i][0], by_value);
        vpi_printf("%s attempts started at:", tags[i]);
        for (j = 0; j < n_starts[i]; j++)
            vpi_printf(" %d", starts[i][j]);
        vpi_printf("\n");
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
    add_task("$vt_system", system_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
