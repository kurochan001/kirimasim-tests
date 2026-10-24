/* VPI application of test_vpi_put_value_event_vector_scaled (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_event_vector_scaled"

static vpiHandle object(const char *name)
{
    char full[96];
    strcpy(full, TOP ".");
    strcat(full, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void put_scaled(const char *name)
{
    vpiHandle h = object(name);
    s_vpi_value v;
    s_vpi_time t;

    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s not found\n", name);
        return;
    }
    v.format = vpiIntVal;
    v.value.integer = 1;
    t.type = vpiScaledRealTime;
    t.high = 0;
    t.low = 0;
    t.real = 3.0;
    vpi_put_value(h, &v, &t, vpiPureTransportDelay);
}

static PLI_INT32 at_5(p_cb_data cb)
{
    vpiHandle ev = object("ev"), pv = object("pv"), w = object("w");
    s_vpi_value v;
    s_vpi_vecval bits8[1], bits40[2];

    (void)cb;
    if (ev == NULL || pv == NULL || w == NULL) {
        vpi_printf((PLI_BYTE8 *)"objects not found\n");
        return 0;
    }
    vpi_put_value(ev, NULL, NULL, vpiNoDelay);

    bits8[0].aval = 0x66;
    bits8[0].bval = 0xcc;
    v.format = vpiVectorVal;
    v.value.vector = bits8;
    vpi_put_value(pv, &v, NULL, vpiNoDelay);

    bits40[0].aval = 0xffffffffu;
    bits40[0].bval = 0;
    bits40[1].aval = 1;
    bits40[1].bval = 2;
    v.format = vpiVectorVal;
    v.value.vector = bits40;
    vpi_put_value(w, &v, NULL, vpiNoDelay);

    put_scaled("t_top");
    put_scaled("u_sub.s_sub");
    return 0;
}

static PLI_INT32 at_8(p_cb_data cb)
{
    vpiHandle ev = object("ev");
    s_vpi_value zero;

    (void)cb;
    zero.format = vpiIntVal;
    zero.value.integer = 0;
    if (ev != NULL)
        vpi_put_value(ev, &zero, NULL, vpiNoDelay);
    return 0;
}

static void after(PLI_UINT32 delay, PLI_INT32 (*rtn)(p_cb_data))
{
    static s_vpi_time times[2];
    static int used = 0;
    s_cb_data cb;

    times[used].type = vpiSimTime;
    times[used].high = 0;
    times[used].low = delay;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = rtn;
    cb.time = &times[used++];
    vpi_register_cb(&cb);
}

static PLI_INT32 on_start(p_cb_data data)
{
    (void)data;
    after(5, at_5);
    after(8, at_8);
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
