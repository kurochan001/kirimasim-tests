/* VPI application of test_vpi_put_value_net_deposit (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_net_deposit."

static vpiHandle object(const char *name)
{
    char full[96];
    strcpy(full, TOP);
    strcat(full, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void put(vpiHandle h, int value, PLI_INT32 mode)
{
    s_vpi_value v;
    s_vpi_time t;

    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"object not found\n");
        return;
    }
    v.format = vpiIntVal;
    v.value.integer = value;
    t.type = vpiSimTime;
    t.high = 0;
    t.low = 2;
    t.real = 0.0;
    vpi_put_value(h, &v, mode == vpiNoDelay ? NULL : &t, mode);
}

static PLI_INT32 at_5(p_cb_data cb)
{
    vpiHandle n_bit = object("n_bit");

    (void)cb;
    put(object("n_nd"), 99, vpiNoDelay);
    put(object("n_in"), 99, vpiInertialDelay);
    put(object("n_tr"), 99, vpiTransportDelay);
    put(object("n_pt"), 99, vpiPureTransportDelay);
    put(n_bit ? vpi_handle_by_index(n_bit, 0) : NULL, 1, vpiNoDelay);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time five;
    s_cb_data cb;

    (void)data;
    five.type = vpiSimTime;
    five.high = 0;
    five.low = 5;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = at_5;
    cb.time = &five;
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
