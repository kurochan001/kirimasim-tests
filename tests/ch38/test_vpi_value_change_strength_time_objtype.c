/* VPI application of test_vpi_value_change_strength_time_objtype (IEEE 1800-2023 38.36.1). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_value_change_strength_time_objtype."

static const char *strength_name(PLI_INT32 s)
{
    return s == vpiStrongDrive ? "vpiStrongDrive" : s == vpiWeakDrive ? "vpiWeakDrive"
           : s == vpiPullDrive ? "vpiPullDrive" : s == vpiSupplyDrive ? "vpiSupplyDrive"
           : "another";
}

static PLI_INT32 on_change(p_cb_data cb)
{
    p_vpi_value v = cb->value;
    int t = cb->time ? (int)cb->time->low : -1;

    if (v == NULL) {
        vpi_printf((PLI_BYTE8 *)"%d: %s: no value\n", t, cb->user_data);
        return 0;
    }
    switch (v->format) {
    case vpiStrengthVal:
        vpi_printf((PLI_BYTE8 *)"%d: %s: logic %s, s1 %s\n", t, cb->user_data,
                   v->value.strength->logic == vpi1 ? "vpi1" : "not vpi1",
                   strength_name(v->value.strength->s1));
        break;
    case vpiBinStrVal:
        vpi_printf((PLI_BYTE8 *)"%d: %s: %s\n", t, cb->user_data, v->value.str);
        break;
    case vpiTimeVal:
        vpi_printf((PLI_BYTE8 *)"%d: %s: high %u low %u\n", t, cb->user_data,
                   (unsigned)v->value.time->high, (unsigned)v->value.time->low);
        break;
    case vpiIntVal:
        vpi_printf((PLI_BYTE8 *)"%d: %s: format vpiIntVal, %d\n", t, cb->user_data,
                   (int)v->value.integer);
        break;
    case vpiRealVal:
        vpi_printf((PLI_BYTE8 *)"%d: %s: format vpiRealVal, %.2f\n", t, cb->user_data,
                   v->value.real);
        break;
    case vpiVectorVal:
        vpi_printf((PLI_BYTE8 *)"%d: %s: format vpiVectorVal, aval %03x bval %03x\n", t,
                   cb->user_data, (unsigned)(v->value.vector[0].aval & 0xfff),
                   (unsigned)(v->value.vector[0].bval & 0xfff));
        break;
    default:
        vpi_printf((PLI_BYTE8 *)"%d: %s: another format\n", t, cb->user_data);
    }
    return 0;
}

static void watch(const char *name, PLI_INT32 format, const char *label)
{
    static s_vpi_time sim_time;
    static s_vpi_value values[6];
    static int used = 0;
    char full[96];
    s_cb_data cb;

    strcpy(full, TOP);
    strcat(full, name);
    sim_time.type = vpiSimTime;
    values[used].format = format;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbValueChange;
    cb.cb_rtn = on_change;
    cb.obj = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    cb.time = &sim_time;
    cb.value = &values[used++];
    cb.user_data = (PLI_BYTE8 *)label;
    if (cb.obj == NULL || vpi_register_cb(&cb) == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not registered\n", label);
}

static PLI_INT32 at_1(p_cb_data data)
{
    (void)data;
    watch("n", vpiStrengthVal, "n vpiStrengthVal");
    watch("n", vpiBinStrVal, "n vpiBinStrVal");
    watch("tv", vpiTimeVal, "tv vpiTimeVal");
    watch("iv", vpiObjTypeVal, "iv vpiObjTypeVal");
    watch("rv", vpiObjTypeVal, "rv vpiObjTypeVal");
    watch("vec", vpiObjTypeVal, "vec vpiObjTypeVal");
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    s_cb_data cb;

    (void)data;
    one.type = vpiSimTime;
    one.high = 0;
    one.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = at_1;
    cb.time = &one;
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
