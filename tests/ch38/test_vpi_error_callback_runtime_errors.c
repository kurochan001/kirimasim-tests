/* VPI application of test_vpi_error_callback_runtime_errors (IEEE 1800-2023 38.36.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 16

static int error_times[MAX], n_errors, right_reason = 1;

static PLI_INT32 on_error(p_cb_data cb)
{
    s_vpi_time t;

    if (cb->reason != cbError)
        right_reason = 0;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    if (n_errors < MAX)
        error_times[n_errors] = (int)t.low;
    n_errors++;
    return 0;
}

static PLI_INT32 end_of_simulation(p_cb_data cb)
{
    int i;

    (void)cb;
    vpi_printf((PLI_BYTE8 *)"cbError calls: %d, reason cbError %d, at:", n_errors, right_reason);
    for (i = 0; i < n_errors && i < MAX; i++)
        vpi_printf((PLI_BYTE8 *)" %d", error_times[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbError;
    cb.cb_rtn = on_error;
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
