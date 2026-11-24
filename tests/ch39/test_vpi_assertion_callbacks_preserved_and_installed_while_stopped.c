#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_callbacks_preserved_and_installed_while_stopped"

static int successes[2];
static int failures[2];

static int read_index(void)
{
    vpiHandle iterator = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle argument = iterator == NULL ? NULL : vpi_scan(iterator);
    if (argument == NULL)
        return -1;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(argument, &value);
    vpi_release_handle(iterator);
    return (int)value.value.integer;
}

static PLI_INT32 record_result(PLI_INT32 reason, p_vpi_time when, vpiHandle assertion,
                               p_vpi_attempt_info attempt, PLI_BYTE8 *user_data)
{
    (void)when;
    (void)assertion;
    (void)attempt;
    (void)reason;
    if (user_data != NULL)
        ++*(int *)user_data;
    return 0;
}

static PLI_INT32 place(PLI_BYTE8 *user_data)
{
    (void)user_data;
    int set = read_index();
    if (set < 0 || set > 1)
        return 0;
    vpiHandle good = vpi_handle_by_name((PLI_BYTE8 *)TOP ".good", NULL);
    vpiHandle bad = vpi_handle_by_name((PLI_BYTE8 *)TOP ".bad", NULL);
    if (good == NULL || bad == NULL) {
        vpi_printf("assertion handle not found\n");
        return 0;
    }
    vpiHandle pass = vpi_register_assertion_cb(
        good, cbAssertionSuccess, record_result, (PLI_BYTE8 *)&successes[set]);
    vpiHandle fail = vpi_register_assertion_cb(
        bad, cbAssertionFailure, record_result, (PLI_BYTE8 *)&failures[set]);
    vpi_printf("registered %s=%d%d\n", set == 0 ? "early" : "late",
               pass != NULL, fail != NULL);
    return 0;
}

static PLI_INT32 switch_system(PLI_BYTE8 *user_data)
{
    (void)user_data;
    int enabled = read_index();
    if (enabled == 0 || enabled == 1)
        vpi_control(enabled ? vpiAssertionSysOn : vpiAssertionSysOff, (vpiHandle)NULL);
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *user_data)
{
    (void)user_data;
    s_vpi_time when = {0};
    when.type = vpiSimTime;
    vpi_get_time(NULL, &when);
    vpi_printf("%u old pass/fail=%d/%d new pass/fail=%d/%d\n", (unsigned)when.low,
               successes[0], failures[0], successes[1], failures[1]);
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*method)(PLI_BYTE8 *))
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)name;
    task.calltf = method;
    vpi_register_systf(&task);
}

static void register_setup(void)
{
    add_task("$vt_place_callbacks", place);
    add_task("$vt_assertion_system_switch", switch_system);
    add_task("$vt_report_callbacks", report);
}

void (*vlog_startup_routines[])(void) = {register_setup, NULL};

#ifdef __cplusplus
}
#endif
