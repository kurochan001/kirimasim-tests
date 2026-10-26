/* VPI application of test_vpi_time_callback_reentrant (IEEE 1800-2023 38.36.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 second(p_cb_data data)
{
    (void)data;
    vpi_printf("%d: second start of time\n", now());
    return 0;
}

static PLI_INT32 first(p_cb_data data)
{
    static s_vpi_time when;
    s_cb_data cb;

    (void)data;
    vpi_printf("%d: first start of time\n", now());
    memset(&cb, 0, sizeof cb);
    when.type = vpiSimTime;
    when.high = 0;
    when.low = now();
    cb.reason = cbAtStartOfSimTime;
    cb.cb_rtn = second;
    cb.time = &when;
    vpi_printf("register second: %d\n", vpi_register_cb(&cb) != NULL ? 1 : 0);
    return 0;
}

static PLI_INT32 setup_calltf(PLI_BYTE8 *user_data)
{
    static s_vpi_time when;
    s_cb_data cb;

    (void)user_data;
    memset(&cb, 0, sizeof cb);
    when.type = vpiSimTime;
    when.high = 0;
    when.low = 5;
    cb.reason = cbAtStartOfSimTime;
    cb.cb_rtn = first;
    cb.time = &when;
    vpi_printf("register first: %d\n", vpi_register_cb(&cb) != NULL ? 1 : 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_setup";
    d.calltf = setup_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
