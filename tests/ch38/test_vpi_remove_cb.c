/* VPI application of test_vpi_remove_cb (IEEE 1800-2023 38.39). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle change_cb, delay_cb;

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_change(p_cb_data cb)
{
    vpi_printf("%d: r changed to %d\n", now(), (int)cb->value->value.integer);
    return 0;
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    (void)cb;
    vpi_printf("%d: delay callback\n", now());
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    static s_vpi_time t, at;
    static s_vpi_value v;
    s_cb_data cb;

    (void)user_data;
    memset(&cb, 0, sizeof cb);
    t.type = vpiSimTime;
    v.format = vpiIntVal;
    cb.reason = cbValueChange;
    cb.cb_rtn = on_change;
    cb.obj = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_remove_cb.r", NULL);
    cb.time = &t;
    cb.value = &v;
    change_cb = vpi_register_cb(&cb);

    memset(&cb, 0, sizeof cb);
    at.type = vpiSimTime;
    at.high = 0;
    at.low = 30;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &at;
    delay_cb = vpi_register_cb(&cb);
    return 0;
}

static PLI_INT32 unwatch_calltf(PLI_BYTE8 *user_data)
{
    PLI_INT32 first, second;

    (void)user_data;
    first = vpi_remove_cb(change_cb);
    second = vpi_remove_cb(delay_cb);
    vpi_printf("%d: vpi_remove_cb returns %d and %d\n", now(), (int)first, (int)second);
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
    add_task("$vt_unwatch", unwatch_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
