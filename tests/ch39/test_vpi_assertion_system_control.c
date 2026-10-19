/* VPI application of test_vpi_assertion_system_control (IEEE 1800-2023 39.5.1, 39.4.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

struct pair {
    const char *name;
    PLI_INT32 code;
};

static const struct pair controls[] = {
    {"on", vpiAssertionSysOn},
    {"off", vpiAssertionSysOff},
    {"kill", vpiAssertionSysKill},
    {"end", vpiAssertionSysEnd},
    {"disable pass action", vpiAssertionSysDisablePassAction},
    {"enable pass action", vpiAssertionSysEnablePassAction},
    {"disable fail action", vpiAssertionSysDisableFailAction},
    {"enable fail action", vpiAssertionSysEnableFailAction},
};

static const struct pair reasons[] = {
    {"on", cbAssertionSysOn},
    {"off", cbAssertionSysOff},
    {"kill", cbAssertionSysKill},
    {"pass action disabled", cbAssertionSysDisablePassAction},
    {"pass action enabled", cbAssertionSysEnablePassAction},
    {"fail action disabled", cbAssertionSysDisableFailAction},
    {"fail action enabled", cbAssertionSysEnableFailAction},
};

#define COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

static int initialized, controlled;

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_initialized(p_cb_data cb)
{
    (void)cb;
    initialized++;
    return 0;
}

static PLI_INT32 on_system(p_cb_data cb)
{
    if (controlled)
        vpi_printf("%d: system callback: %s\n", now(), cb->user_data);
    return 0;
}

static void place(PLI_INT32 reason, PLI_INT32 (*rtn)(p_cb_data), const char *name)
{
    s_cb_data cb;
    memset(&cb, 0, sizeof cb);
    cb.reason = reason;
    cb.cb_rtn = rtn;
    cb.user_data = (PLI_BYTE8 *)name;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf("%s: callback not placed\n", name);
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
    vpi_free_object(it);
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

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("assertion system initialized: %d time(s)\n", initialized);
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
    int i;

    add_task("$vt_system", system_calltf);
    add_task("$vt_report", report_calltf);
    place(cbAssertionSysInitialized, on_initialized, "initialized");
    for (i = 0; i < COUNT(reasons); i++)
        place(reasons[i].code, on_system, reasons[i].name);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
