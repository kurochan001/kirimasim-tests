/* VPI application of test_vpi_put_value_caller_storage_time_strength (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_caller_storage_time_strength."

static vpiHandle tv_obj, sn_obj;

/* The structures of the puts, which change after the calls. */
static s_vpi_value value;
static s_vpi_time time_value;
static s_vpi_strengthval strength;
static s_vpi_time delay;

static const char *scalar_name(PLI_INT32 v)
{
    return v == vpi0 ? "vpi0" : v == vpi1 ? "vpi1" : v == vpiX ? "vpiX" : v == vpiZ ? "vpiZ"
           : "another";
}

static const char *strength_name(PLI_INT32 s)
{
    return s == vpiSupplyDrive ? "vpiSupplyDrive" : s == vpiStrongDrive ? "vpiStrongDrive"
           : s == vpiPullDrive ? "vpiPullDrive" : s == vpiWeakDrive ? "vpiWeakDrive"
           : "another strength";
}

static PLI_INT32 show(p_cb_data cb)
{
    s_vpi_value t, s;

    t.format = vpiTimeVal;
    vpi_get_value(tv_obj, &t);
    s.format = vpiStrengthVal;
    vpi_get_value(sn_obj, &s);
    vpi_printf((PLI_BYTE8 *)"%s: tv high %u low %u, sn logic %s", cb->user_data,
               (unsigned)t.value.time->high, (unsigned)t.value.time->low,
               scalar_name(s.value.strength->logic));
    if (s.value.strength->logic == vpi1)
        vpi_printf((PLI_BYTE8 *)", s1 %s", strength_name(s.value.strength->s1));
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static PLI_INT32 at_1(p_cb_data cb)
{
    (void)cb;
    delay.type = vpiSimTime;
    delay.high = 0;
    delay.low = 4;

    time_value.type = vpiSimTime;
    time_value.high = 3;
    time_value.low = 9;
    value.format = vpiTimeVal;
    value.value.time = &time_value;
    vpi_put_value(tv_obj, &value, &delay, vpiInertialDelay);

    strength.logic = vpi1;
    strength.s0 = vpiWeakDrive;
    strength.s1 = vpiWeakDrive;
    value.format = vpiStrengthVal;
    value.value.strength = &strength;
    vpi_put_value(sn_obj, &value, &delay, vpiInertialDelay);

    /* The structures change before the events happen. */
    time_value.high = 0;
    time_value.low = 1;
    strength.logic = vpi0;
    strength.s0 = vpiStrongDrive;
    strength.s1 = vpiStrongDrive;
    value.format = vpiIntVal;
    value.value.integer = 0;
    delay.low = 8;
    return 0;
}

static void after(PLI_UINT32 when, PLI_INT32 (*rtn)(p_cb_data), const char *label)
{
    static s_vpi_time times[3];
    static int used = 0;
    s_cb_data cb;

    times[used].type = vpiSimTime;
    times[used].high = 0;
    times[used].low = when;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = rtn;
    cb.time = &times[used++];
    cb.user_data = (PLI_BYTE8 *)label;
    vpi_register_cb(&cb);
}

static PLI_INT32 on_start(p_cb_data data)
{
    (void)data;
    tv_obj = vpi_handle_by_name((PLI_BYTE8 *)TOP "tv", NULL);
    sn_obj = vpi_handle_by_name((PLI_BYTE8 *)TOP "sn", NULL);
    if (tv_obj == NULL || sn_obj == NULL) {
        vpi_printf((PLI_BYTE8 *)"objects not found\n");
        return 0;
    }
    after(1, at_1, "1");
    after(4, show, "4");
    after(6, show, "6");
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
