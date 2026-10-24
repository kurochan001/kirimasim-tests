/* VPI application of test_vpi_get_value_obj_type_real_vector (IEEE 1800-2023 38.15). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get_value_obj_type_real_vector."

static const char *format_name(PLI_INT32 f)
{
    return f == vpiRealVal ? "vpiRealVal" : f == vpiVectorVal ? "vpiVectorVal"
           : f == vpiScalarVal ? "vpiScalarVal" : f == vpiStrengthVal ? "vpiStrengthVal"
           : f == vpiIntVal ? "vpiIntVal" : f == vpiObjTypeVal ? "vpiObjTypeVal" : "another";
}

/* scalar: whether the format is one of the two that 38.15 allows for a scalar */
static void show(const char *name, int scalar)
{
    char full[96];
    vpiHandle h;
    s_vpi_value v;

    strcpy(full, TOP);
    strcat(full, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    v.format = vpiObjTypeVal;
    vpi_get_value(h, &v);
    if (scalar)
        vpi_printf((PLI_BYTE8 *)"%s: format vpiScalarVal or vpiStrengthVal %s", name,
                   v.format == vpiScalarVal || v.format == vpiStrengthVal ? "yes" : "no");
    else
        vpi_printf((PLI_BYTE8 *)"%s: format %s", name, format_name(v.format));
    if (v.format == vpiRealVal)
        vpi_printf((PLI_BYTE8 *)", real %.2f\n", v.value.real);
    else if (v.format == vpiVectorVal)
        vpi_printf((PLI_BYTE8 *)", aval %03x bval %03x\n",
                   (unsigned)(v.value.vector[0].aval & 0xfff),
                   (unsigned)(v.value.vector[0].bval & 0xfff));
    else if (v.format == vpiScalarVal)
        vpi_printf((PLI_BYTE8 *)", logic value is vpi1: %s\n",
                   v.value.scalar == vpi1 ? "yes" : "no");
    else if (v.format == vpiStrengthVal)
        vpi_printf((PLI_BYTE8 *)", logic value is vpi1: %s\n",
                   v.value.strength->logic == vpi1 ? "yes" : "no");
    else
        vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    (void)cb;
    show("r", 0);
    show("vec", 0);
    show("s", 1);
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
