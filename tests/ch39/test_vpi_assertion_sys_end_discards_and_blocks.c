/* VPI application of test_vpi_assertion_sys_end_discards_and_blocks (IEEE 1800-2023 39.5.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_sys_end_discards_and_blocks"
#define MAX 32

static int starts[MAX], n_starts, ended, after_end;
static vpiHandle a1;

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_start(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                          p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    (void)reason;
    (void)cb_time;
    (void)assertion;
    (void)info;
    (void)user_data;
    if (ended)
        after_end++;
    if (n_starts < MAX)
        starts[n_starts++] = now();
    return 0;
}

static PLI_INT32 on_system(p_cb_data cb)
{
    (void)cb;
    if (ended)
        after_end++;
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    static const PLI_INT32 reasons[] = {cbAssertionSysOn, cbAssertionSysOff};
    s_cb_data cb;
    int i;

    (void)user_data;
    a1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a1", NULL);
    if (a1 == NULL) {
        vpi_printf((PLI_BYTE8 *)"a1 not found\n");
        return 0;
    }
    if (vpi_register_assertion_cb(a1, cbAssertionStart, on_start, NULL) == NULL)
        vpi_printf((PLI_BYTE8 *)"a1: start callback not placed\n");
    for (i = 0; i < 2; i++) {
        memset(&cb, 0, sizeof cb);
        cb.reason = reasons[i];
        cb.cb_rtn = on_system;
        if (vpi_register_cb(&cb) == NULL)
            vpi_printf((PLI_BYTE8 *)"system callback %d not placed\n", i);
    }
    return 0;
}

static PLI_INT32 end_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_control(vpiAssertionSysEnd, (vpiHandle)NULL);
    ended = 1;
    return 0;
}

static PLI_INT32 system_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    (void)user_data;
    if (arg == NULL) {
        vpi_printf((PLI_BYTE8 *)"$vt_system: no argument\n");
        return 0;
    }
    vpi_release_handle(it);
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    if (strcmp(v.value.str, "on") == 0)
        vpi_control(vpiAssertionSysOn, (vpiHandle)NULL);
    else if (strcmp(v.value.str, "off") == 0)
        vpi_control(vpiAssertionSysOff, (vpiHandle)NULL);
    else
        vpi_printf((PLI_BYTE8 *)"$vt_system: unknown control %s\n", v.value.str);
    return 0;
}

static PLI_INT32 enable_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (a1 != NULL)
        vpi_control(vpiAssertionEnable, a1);
    return 0;
}

static int by_value(const void *pa, const void *pb)
{
    return *(const int *)pa - *(const int *)pb;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    qsort(starts, n_starts, sizeof starts[0], by_value);
    vpi_printf((PLI_BYTE8 *)"a1 attempts started at:");
    for (i = 0; i < n_starts; i++)
        vpi_printf((PLI_BYTE8 *)" %d", starts[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
    vpi_printf((PLI_BYTE8 *)"callbacks after the end: %d\n", after_end);
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
    add_task("$vt_end", end_calltf);
    add_task("$vt_system", system_calltf);
    add_task("$vt_enable", enable_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
