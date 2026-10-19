/* VPI application of test_vpi_assertion_control (IEEE 1800-2023 39.5.2, 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_control"

struct pair {
    const char *name;
    PLI_INT32 code;
};

static const struct pair controls[] = {
    {"disable", vpiAssertionDisable},
    {"enable", vpiAssertionEnable},
    {"lock", vpiAssertionLock},
    {"unlock", vpiAssertionUnlock},
    {"disable pass action", vpiAssertionDisablePassAction},
    {"enable pass action", vpiAssertionEnablePassAction},
    {"disable fail action", vpiAssertionDisableFailAction},
    {"enable fail action", vpiAssertionEnableFailAction},
    {"disable vacuous action", vpiAssertionDisableVacuousAction},
    {"enable nonvacuous action", vpiAssertionEnableNonvacuousAction},
};

static const struct pair reasons[] = {
    {"disabled", cbAssertionDisable},
    {"enabled", cbAssertionEnable},
    {"locked", cbAssertionLock},
    {"unlocked", cbAssertionUnlock},
    {"pass action disabled", cbAssertionDisablePassAction},
    {"pass action enabled", cbAssertionEnablePassAction},
    {"fail action disabled", cbAssertionDisableFailAction},
    {"fail action enabled", cbAssertionEnableFailAction},
    {"vacuous action disabled", cbAssertionDisableVacuousAction},
    {"nonvacuous action enabled", cbAssertionEnableNonvacuousAction},
};

#define COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

static char tags[2][3] = {"a1", "a2"};
static vpiHandle watched[2];

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_change(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                           p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    const char *what = "other reason";
    int i;

    (void)cb_time;
    (void)assertion;
    for (i = 0; i < COUNT(reasons); i++)
        if (reasons[i].code == reason)
            what = reasons[i].name;
    vpi_printf("%d: callback: %s %s, attempt information %s\n", now(), user_data, what,
               info == NULL ? "NULL" : "given");
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    char full[64];
    int i, j;

    (void)user_data;
    for (i = 0; i < 2; i++) {
        snprintf(full, sizeof full, "%s.%s", TOP, tags[i]);
        watched[i] = vpi_handle_by_name(full, NULL);
        if (watched[i] == NULL) {
            vpi_printf("%s not found\n", full);
            continue;
        }
        for (j = 0; j < COUNT(reasons); j++)
            if (vpi_register_assertion_cb(watched[i], reasons[j].code, on_change, tags[i]) == NULL)
                vpi_printf("%s: %s callback not placed\n", tags[i], reasons[j].name);
    }
    return 0;
}

/* Returns a copy of the string value of the next argument. */
static char *next_string(vpiHandle it)
{
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;
    char *copy;

    if (arg == NULL)
        return NULL;
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    copy = (char *)malloc(strlen(v.value.str) + 1);
    strcpy(copy, v.value.str);
    return copy;
}

static PLI_INT32 control_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    char *name = next_string(it), *op = next_string(it);
    int i, which = -1;

    (void)user_data;
    if (it)
        vpi_free_object(it);
    for (i = 0; i < 2; i++)
        if (name && strcmp(name, tags[i]) == 0)
            which = i;
    for (i = 0; i < COUNT(controls); i++)
        if (op && which >= 0 && watched[which] && strcmp(op, controls[i].name) == 0) {
            vpi_control(controls[i].code, watched[which]);
            return 0;
        }
    vpi_printf("$vt_control: bad arguments\n");
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
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
