/* VPI application of test_pli_pre_active_write (IEEE 1800-2023 4.4.3.2, 38.36.2). */
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

static PLI_INT32 on_delay(p_cb_data cb)
{
    vpiHandle v = var("test_pli_pre_active_write.v");
    s_vpi_value val;
    s_vpi_time now;

    (void)cb;
    now.type = vpiSimTime;
    vpi_get_time(NULL, &now);
    vpi_printf("cbAfterDelay at %d: a=%d, writes v=5\n", (int)now.low,
               value_of("test_pli_pre_active_write.a"));
    if (v == NULL)
        return 0;
    val.format = vpiIntVal;
    val.value.integer = 5;
    vpi_put_value(v, &val, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 register_calltf(PLI_BYTE8 *user_data)
{
    s_cb_data cb;
    s_vpi_time t;

    (void)user_data;
    memset(&cb, 0, sizeof cb);
    memset(&t, 0, sizeof t);
    t.type = vpiSimTime;
    t.low = 10;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &t;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf("cbAfterDelay could not be registered\n");
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
