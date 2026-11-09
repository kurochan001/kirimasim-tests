/* VPI application of test_pli_callback_immediate_and_one_shot
   (IEEE 1800-2023 4.10, 38.36.1, 38.36.2). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle var_v(void)
{
    return vpi_handle_by_name((PLI_BYTE8 *)"test_pli_callback_immediate_and_one_shot.v", NULL);
}

static int value_of_v(void)
{
    vpiHandle h = var_v();
    s_vpi_value v;

    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

/* Called at each change of v, with the new value. */
static PLI_INT32 on_change(p_cb_data cb)
{
    vpi_printf("cbValueChange at %d: v=%d\n", (int)cb->time->low,
               cb->value ? (int)cb->value->value.integer : -1);
    return 0;
}

/* Called once, 10 after the registration. */
static PLI_INT32 on_delay(p_cb_data cb)
{
    vpi_printf("cbAfterDelay at %d: v=%d\n", (int)cb->time->low, value_of_v());
    return 0;
}

static PLI_INT32 register_calltf(PLI_BYTE8 *user_data)
{
    static s_vpi_time change_time, delay_time;
    static s_vpi_value change_value;
    s_cb_data cb;

    (void)user_data;
    memset(&cb, 0, sizeof cb);
    change_time.type = vpiSimTime;
    change_value.format = vpiIntVal;
    cb.reason = cbValueChange;
    cb.cb_rtn = on_change;
    cb.obj = var_v();
    cb.time = &change_time;
    cb.value = &change_value;
    if (cb.obj == NULL || vpi_register_cb(&cb) == NULL)
        vpi_printf("cbValueChange could not be registered\n");

    memset(&cb, 0, sizeof cb);
    memset(&delay_time, 0, sizeof delay_time);
    delay_time.type = vpiSimTime;
    delay_time.low = 10;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &delay_time;
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
