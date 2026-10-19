/* VPI application of test_vpi_simulation_action_callbacks (IEEE 1800-2023 36.9.2, 38.36.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *const names[] = {"end of compile", "start of simulation", "end of simulation"};
static const PLI_INT32 reasons[] = {cbEndOfCompile, cbStartOfSimulation, cbEndOfSimulation};

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_action(p_cb_data cb)
{
    int k = (int)(cb->user_data - (PLI_BYTE8 *)names);
    vpiHandle r;

    if (k < 0 || k > 2 || cb->reason != reasons[k]) {
        vpi_printf("callback with a wrong reason or user_data\n");
        return 0;
    }
    if (cb->reason == cbEndOfCompile) {
        r = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_simulation_action_callbacks.r", NULL);
        vpi_printf("%s: r has %d bits\n", names[k], r ? (int)vpi_get(vpiSize, r) : -1);
    } else {
        vpi_printf("%s at %d\n", names[k], now());
    }
    return 0;
}

static void register_all(void)
{
    int k;

    for (k = 0; k < 3; k++) {
        s_cb_data cb;
        memset(&cb, 0, sizeof cb);
        cb.reason = reasons[k];
        cb.cb_rtn = on_action;
        cb.user_data = (PLI_BYTE8 *)names + k;
        vpi_register_cb(&cb);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
