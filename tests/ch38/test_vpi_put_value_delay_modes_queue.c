/* VPI application of test_vpi_put_value_delay_modes_queue (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_delay_modes_queue."

static void put_after(vpiHandle h, int value, PLI_UINT32 delay, PLI_INT32 mode)
{
    s_vpi_value v;
    s_vpi_time t;

    v.format = vpiIntVal;
    v.value.integer = value;
    t.type = vpiSimTime;
    t.high = 0;
    t.low = delay;
    t.real = 0.0;
    vpi_put_value(h, &v, &t, mode);
}

static void schedule(const char *name, PLI_INT32 mode)
{
    char full[96];
    vpiHandle h;

    strcpy(full, TOP);
    strcat(full, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    put_after(h, 1, 10, vpiPureTransportDelay);
    put_after(h, 2, 30, vpiPureTransportDelay);
    put_after(h, 3, 20, mode);
}

static PLI_INT32 at_10(p_cb_data cb)
{
    (void)cb;
    schedule("in_v", vpiInertialDelay);
    schedule("tr_v", vpiTransportDelay);
    schedule("pt_v", vpiPureTransportDelay);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time ten;
    s_cb_data cb;

    (void)data;
    ten.type = vpiSimTime;
    ten.high = 0;
    ten.low = 10;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = at_10;
    cb.time = &ten;
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
