/* VPI application of test_vpi_assertion_cover_no_failure (IEEE 1800-2023 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_cover_no_failure"

static vpiHandle watched;
static int failures;

static PLI_INT32 on_failure(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                            p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    (void)cb_time;
    (void)info;
    (void)user_data;
    if (reason != cbAssertionFailure || !vpi_compare_objects(assertion, watched)) {
        vpi_printf("callback with a wrong reason or assertion\n");
        return 0;
    }
    failures++;
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    watched = vpi_handle_by_name((PLI_BYTE8 *)TOP ".c1", NULL);
    if (watched == NULL) {
        vpi_printf("%s.c1 not found\n", TOP);
        return 0;
    }
    if (vpi_register_assertion_cb(watched, cbAssertionFailure, on_failure, NULL) == NULL)
        vpi_printf("cbAssertionFailure not placed\n");
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("failure callbacks: %d\n", failures);
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
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
