/* VPI application of test_vpi_chk_error_pli_error_callback (IEEE 1800-2023 36.10.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int error_callbacks;
static int level_nonzero, level_in_info, cleared;

/* Makes no VPI call, so that it cannot change the error status. */
static PLI_INT32 on_pli_error(p_cb_data cb)
{
    if (cb->reason == cbPLIError)
        error_callbacks++;
    return 0;
}

static PLI_INT32 never(p_cb_data cb)
{
    (void)cb;
    return 0;
}

static PLI_INT32 end_of_simulation(p_cb_data cb)
{
    (void)cb;
    vpi_printf((PLI_BYTE8 *)"failed registration: vpi_chk_error nonzero %d, "
               "same level in the error information %d\n", level_nonzero, level_in_info);
    vpi_printf((PLI_BYTE8 *)"after a vpi_get_time that succeeded: vpi_chk_error 0 %d\n", cleared);
    vpi_printf((PLI_BYTE8 *)"cbPLIError callback: called %d\n", error_callbacks > 0);
    return 0;
}

static PLI_INT32 start_of_simulation(p_cb_data start)
{
    s_cb_data cb;
    s_vpi_time t;
    s_vpi_error_info info;
    PLI_INT32 level;
    (void)start;
    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSuppressTime;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = never;
    cb.time = &t;
    vpi_register_cb(&cb);
    memset(&info, 0, sizeof info);
    level = vpi_chk_error(&info);
    level_nonzero = level != 0;
    level_in_info = level != 0 && info.level == level;

    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    cleared = vpi_chk_error(NULL) == 0;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfSimulation;
    cb.cb_rtn = end_of_simulation;
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbPLIError;
    cb.cb_rtn = on_pli_error;
    vpi_register_cb(&cb);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
