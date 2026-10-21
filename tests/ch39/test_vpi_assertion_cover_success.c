/* VPI application of test_vpi_assertion_cover_success (IEEE 1800-2023 39.4.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_cover_success"

static vpiHandle watched;
static int successes;

static int ticks(p_vpi_time t)
{
    if (t == NULL)
        return -1;
    if (t->type == vpiScaledRealTime)
        return (int)(t->real + 0.5);
    return (int)t->low;
}

static PLI_INT32 on_success(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                            p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    int start = info ? ticks(&info->attemptStartTime) : -1;

    (void)user_data;
    if (reason != cbAssertionSuccess || !vpi_compare_objects(assertion, watched)) {
        vpi_printf("callback with a wrong reason or assertion\n");
        return 0;
    }
    successes++;
    vpi_printf("success at %d, attempt started at %d\n", ticks(cb_time), start);
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
    if (vpi_register_assertion_cb(watched, cbAssertionSuccess, on_success, NULL) == NULL)
        vpi_printf("cbAssertionSuccess not placed\n");
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("success callbacks: %d\n", successes);
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
