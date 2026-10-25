/* VPI application of test_vpi_routines_chk_error (IEEE 1800-2023 36.11, Table 36-9). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 ignore(p_cb_data data)
{
    (void)data;
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    s_cb_data d;
    s_vpi_error_info err;
    s_vpi_time now;
    PLI_INT32 level, after;

    (void)data;
    memset(&d, 0, sizeof d);
    d.reason = cbAfterDelay;
    d.cb_rtn = ignore;
    d.time = NULL;
    vpi_register_cb(&d);
    memset(&err, 0, sizeof err);
    level = vpi_chk_error(&err);
    now.type = vpiSimTime;
    vpi_get_time(NULL, &now);
    after = vpi_chk_error(NULL);
    vpi_printf("after the failed registration: error %d, a level of Table 38-1 %d, "
               "the same in the structure %d\n", level != 0,
               level >= vpiNotice && level <= vpiInternal, err.level == level);
    vpi_printf("after a vpi_get_time that succeeded: %d\n", (int)after);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
