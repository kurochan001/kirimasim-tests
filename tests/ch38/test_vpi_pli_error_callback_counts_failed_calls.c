/* VPI application of test_vpi_pli_error_callback_counts_failed_calls (IEEE 1800-2023 38.36.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int pli_errors, failed_registrations, reads_ok;

/* Makes no VPI call, so that it cannot cause an error itself. */
static PLI_INT32 on_pli_error(p_cb_data cb)
{
    if (cb->reason == cbPLIError)
        pli_errors++;
    return 0;
}

static PLI_INT32 never(p_cb_data cb)
{
    (void)cb;
    return 0;
}

/* VPI calls that succeed: they read the time, find r and read its size. */
static void good_calls(void)
{
    s_vpi_time t;
    vpiHandle r;

    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    r = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_pli_error_callback_counts_failed_calls.r", NULL);
    if (r != NULL && vpi_get(vpiSize, r) == 8)
        reads_ok++;
}

static void failing_registration(int null_time)
{
    s_cb_data cb;
    s_vpi_time t;

    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSuppressTime;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = never;
    cb.time = null_time ? NULL : &t;
    if (vpi_register_cb(&cb) == NULL)
        failed_registrations++;
}

static PLI_INT32 start_of_simulation(p_cb_data start)
{
    (void)start;
    good_calls();
    failing_registration(0);
    failing_registration(1);
    good_calls();
    return 0;
}

static PLI_INT32 end_of_simulation(p_cb_data cb)
{
    (void)cb;
    vpi_printf((PLI_BYTE8 *)"calls that succeeded found r with size 8: %d of 2\n", reads_ok);
    vpi_printf((PLI_BYTE8 *)"failed registrations: %d of 2\n", failed_registrations);
    vpi_printf((PLI_BYTE8 *)"cbPLIError calls: %d\n", pli_errors);
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

    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfSimulation;
    cb.cb_rtn = end_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
