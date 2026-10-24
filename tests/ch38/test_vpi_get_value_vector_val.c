/* VPI application of test_vpi_get_value_vector_val (IEEE 1800-2023 38.15). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get_value_vector_val."

static PLI_INT32 on_delay(p_cb_data cb)
{
    vpiHandle w = vpi_handle_by_name((PLI_BYTE8 *)TOP "w", NULL);
    vpiHandle v = vpi_handle_by_name((PLI_BYTE8 *)TOP "v", NULL);
    s_vpi_value val;

    (void)cb;
    if (w == NULL || v == NULL) {
        vpi_printf((PLI_BYTE8 *)"objects not found\n");
        return 0;
    }
    val.format = vpiVectorVal;
    vpi_get_value(w, &val);
    vpi_printf((PLI_BYTE8 *)"w element 0: aval %08x bval %08x\n",
               (unsigned)val.value.vector[0].aval, (unsigned)val.value.vector[0].bval);
    vpi_printf((PLI_BYTE8 *)"w element 1, bits 32 to 39: aval %02x bval %02x\n",
               (unsigned)(val.value.vector[1].aval & 0xff),
               (unsigned)(val.value.vector[1].bval & 0xff));
    val.format = vpiVectorVal;
    vpi_get_value(v, &val);
    vpi_printf((PLI_BYTE8 *)"v element 0: aval %08x bval %08x\n",
               (unsigned)val.value.vector[0].aval, (unsigned)val.value.vector[0].bval);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time delay;
    s_cb_data cb;

    (void)data;
    delay.type = vpiSimTime;
    delay.high = 0;
    delay.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &delay;
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
