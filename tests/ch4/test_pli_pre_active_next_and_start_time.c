/* VPI application of test_pli_pre_active_next_and_start_time
   (IEEE 1800-2023 4.10, 4.4.3.2, 38.36.2, 38.34). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle var(const char *name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
}

static int value_of(const char *name)
{
    vpiHandle h = var(name);
    s_vpi_value v;

    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void write_int(const char *name, int value)
{
    vpiHandle h = var(name);
    s_vpi_value v;

    if (h == NULL)
        return;
    v.format = vpiIntVal;
    v.value.integer = value;
    vpi_put_value(h, &v, NULL, vpiNoDelay);
}

/* cbNextSimTime, registered at 0: the next time step with events is 10. */
static PLI_INT32 on_next(p_cb_data cb)
{
    vpi_printf("cbNextSimTime at %d: a=%d\n", (int)cb->time->low,
               value_of("test_pli_pre_active_next_and_start_time.a"));
    write_int("test_pli_pre_active_next_and_start_time.v", 7);
    return 0;
}

/* cbAtStartOfSimTime for time 20. */
static PLI_INT32 on_start(p_cb_data cb)
{
    vpi_printf("cbAtStartOfSimTime at %d: b=%d\n", (int)cb->time->low,
               value_of("test_pli_pre_active_next_and_start_time.b"));
    write_int("test_pli_pre_active_next_and_start_time.w", 5);
    return 0;
}

static void register_time_cb(PLI_INT32 reason, PLI_INT32 (*rtn)(p_cb_data), int at)
{
    s_cb_data cb;
    s_vpi_time t;

    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    t.low = (PLI_UINT32)at;
    cb.reason = reason;
    cb.cb_rtn = rtn;
    cb.time = &t;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf("callback %d could not be registered\n", (int)reason);
}

static PLI_INT32 register_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    register_time_cb(cbNextSimTime, on_next, 0);
    register_time_cb(cbAtStartOfSimTime, on_start, 20);
    return 0;
}

static void register_systf(void)
{
    s_vpi_systf_data tf;

    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask;
    tf.tfname = (PLI_BYTE8 *)"$vt_register";
    tf.calltf = register_calltf;
    vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {register_systf, 0};

#ifdef __cplusplus
}
#endif
