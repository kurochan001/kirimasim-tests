/* VPI application of test_vpi_assertion_callback_handle_placement (IEEE 1800-2023 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_callback_handle_placement"
#define MAX 16

struct call {
    int when;
    char name[16];
};

static struct call calls[MAX];
static int n_calls;
static vpiHandle placed;

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_success(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                            p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    PLI_BYTE8 *name;

    (void)cb_time;
    (void)info;
    (void)user_data;
    if (reason != cbAssertionSuccess || n_calls >= MAX)
        return 0;
    calls[n_calls].when = now();
    name = assertion != NULL ? vpi_get_str(vpiName, assertion) : NULL;
    snprintf(calls[n_calls].name, sizeof calls[n_calls].name, "%s", name ? name : "?");
    n_calls++;
    return 0;
}

static const char *result(vpiHandle h)
{
    return h != NULL ? "handle given" : "NULL";
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle a1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a1", NULL);
    vpiHandle x = vpi_handle_by_name((PLI_BYTE8 *)TOP ".x", NULL);
    vpiHandle bad_object, bad_reason;

    (void)user_data;
    if (a1 == NULL || x == NULL) {
        vpi_printf((PLI_BYTE8 *)"a1 or x not found\n");
        return 0;
    }
    placed = vpi_register_assertion_cb(a1, cbAssertionSuccess, on_success, NULL);
    bad_object = vpi_register_assertion_cb(x, cbAssertionSuccess, on_success, NULL);
    bad_reason = vpi_register_assertion_cb(a1, cbValueChange, on_success, NULL);
    vpi_printf((PLI_BYTE8 *)"%d: cbAssertionSuccess on a1: %s\n", now(), result(placed));
    vpi_printf((PLI_BYTE8 *)"%d: cbAssertionSuccess on the variable x: %s\n", now(),
               result(bad_object));
    vpi_printf((PLI_BYTE8 *)"%d: cbValueChange on a1: %s\n", now(), result(bad_reason));
    return 0;
}

static PLI_INT32 drop_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (placed == NULL) {
        vpi_printf((PLI_BYTE8 *)"%d: no callback to remove\n", now());
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"%d: vpi_remove_cb returns %d\n", now(), (int)vpi_remove_cb(placed));
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    for (i = 0; i < n_calls; i++)
        vpi_printf((PLI_BYTE8 *)"success callback at %d for %s\n", calls[i].when, calls[i].name);
    vpi_printf((PLI_BYTE8 *)"success callbacks: %d\n", n_calls);
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
    add_task("$vt_drop", drop_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
