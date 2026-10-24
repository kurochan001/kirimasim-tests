/* VPI application of test_vpi_assertion_disable_enable_running_attempts (IEEE 1800-2023 39.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_disable_enable_running_attempts"
#define MAX 32

struct pair {
    const char *name;
    PLI_INT32 code;
};

static const struct pair controls[] = {
    {"disable", vpiAssertionDisable},
    {"enable", vpiAssertionEnable},
};

#define COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

static int starts[MAX], n_starts;

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static vpiHandle find(const char *name)
{
    char full[128];
    vpiHandle h;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name(full, NULL);
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s not found\n", full);
    return h;
}

static PLI_INT32 on_start(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                          p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    (void)cb_time;
    (void)assertion;
    (void)info;
    (void)user_data;
    if (reason == cbAssertionStart && n_starts < MAX)
        starts[n_starts++] = now();
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle a1 = find("a1");

    (void)user_data;
    if (a1 != NULL && vpi_register_assertion_cb(a1, cbAssertionStart, on_start, NULL) == NULL)
        vpi_printf((PLI_BYTE8 *)"a1: start callback not placed\n");
    return 0;
}

/* Copies the string value of the next argument into buf. */
static int next_string(vpiHandle it, char *buf, size_t size)
{
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    if (arg == NULL)
        return 0;
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    snprintf(buf, size, "%s", v.value.str);
    return 1;
}

static PLI_INT32 control_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    char name[32], op[32];
    vpiHandle assertion;
    int ok, i;

    (void)user_data;
    ok = next_string(it, name, sizeof name) && next_string(it, op, sizeof op);
    if (it && ok)
        vpi_release_handle(it);
    if (!ok) {
        vpi_printf((PLI_BYTE8 *)"$vt_control: two arguments needed\n");
        return 0;
    }
    assertion = find(name);
    if (assertion == NULL)
        return 0;
    for (i = 0; i < COUNT(controls); i++)
        if (strcmp(op, controls[i].name) == 0) {
            vpi_control(controls[i].code, assertion);
            return 0;
        }
    vpi_printf((PLI_BYTE8 *)"$vt_control: unknown control %s\n", op);
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
