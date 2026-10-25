/* VPI application of test_assertcontrol_callbacks_system (IEEE 1800-2023 20.11, 39.4.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_assertcontrol_callbacks_system"

static int printing;

static int now(void)
{
    s_vpi_time t;

    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

/* cbAssertionSysLock and the other system reasons of 39.4.1 carry no attempt
   information; the user data names the reason. */
static PLI_INT32 on_system(p_cb_data cb)
{
    if (printing)
        vpi_printf("%d: system %s\n", now(), (const char *)cb->user_data);
    return 0;
}

static void place(PLI_INT32 reason, const char *name)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = reason;
    cb.cb_rtn = on_system;
    cb.user_data = (PLI_BYTE8 *)name;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf("%s: callback not placed\n", name);
}

/* Prints the assertion coverage counters of a_cnt (40.5.2). */
static PLI_INT32 counters_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    vpiHandle h;
    s_vpi_value v;
    char label[64] = "counters";
    int attempts, successes, vacuous, failures;

    (void)user_data;
    if (arg != NULL) {
        v.format = vpiStringVal;
        vpi_get_value(arg, &v);
        if (v.value.str != NULL)
            snprintf(label, sizeof label, "%s", v.value.str);
    }
    if (it != NULL)
        vpi_release_handle(it);
    h = vpi_handle_by_name(TOP ".a_cnt", NULL);
    if (h == NULL) {
        vpi_printf("a_cnt not found\n");
        return 0;
    }
    attempts = (int)vpi_get(vpiAssertAttemptCovered, h);
    successes = (int)vpi_get(vpiAssertSuccessCovered, h);
    vacuous = (int)vpi_get(vpiAssertVacuousSuccessCovered, h);
    failures = (int)vpi_get(vpiAssertFailureCovered, h);
    vpi_printf("%d: %s: attempts %d, nonvacuous successes %d, "
               "vacuous successes %d, failures %d\n",
               now(), label, attempts, successes, vacuous, failures);
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 0;
}

static PLI_INT32 begin_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    printing = 1;
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
    add_task("$vt_counters", counters_calltf);
    place(cbAssertionSysLock, "lock");
    place(cbAssertionSysUnlock, "unlock");
    place(cbAssertionSysOn, "on");
    place(cbAssertionSysOff, "off");
    place(cbAssertionSysKill, "kill");
    place(cbAssertionSysEnablePassAction, "enable pass action");
    place(cbAssertionSysDisablePassAction, "disable pass action");
    place(cbAssertionSysEnableFailAction, "enable fail action");
    place(cbAssertionSysDisableFailAction, "disable fail action");
    place(cbAssertionSysEnableNonvacuousAction, "enable nonvacuous action");
    place(cbAssertionSysDisableVacuousAction, "disable vacuous action");
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
