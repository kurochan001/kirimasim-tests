/* VPI application of test_vpi_get_cb_info (IEEE 1800-2023 38.8). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char cb_data_text[] = "after delay data";

static PLI_INT32 on_delay(p_cb_data data)
{
    s_vpi_time t;
    (void)data;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    vpi_printf("t=%d: the callback runs\n", (int)t.low);
    return 0;
}

static PLI_INT32 place_calltf(PLI_BYTE8 *user_data)
{
    static s_vpi_time delay;
    s_cb_data d, info;
    vpiHandle cb;

    (void)user_data;
    memset(&d, 0, sizeof d);
    delay.type = vpiSimTime;
    delay.high = 0;
    delay.low = 5;
    d.reason = cbAfterDelay;
    d.cb_rtn = on_delay;
    d.time = &delay;
    d.user_data = cb_data_text;
    cb = vpi_register_cb(&d);
    if (cb == NULL) {
        vpi_printf("callback not placed\n");
        return 0;
    }
    memset(&info, 0, sizeof info);
    vpi_get_cb_info(cb, &info);
    vpi_printf("reason: %s, routine: %s, user data: \"%s\"\n",
               info.reason == cbAfterDelay ? "cbAfterDelay" : "other",
               info.cb_rtn == on_delay ? "on_delay" : "other",
               info.user_data ? info.user_data : "");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_place";
    d.calltf = place_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
