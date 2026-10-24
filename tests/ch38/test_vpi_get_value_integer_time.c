/* VPI application of test_vpi_get_value_integer_time (IEEE 1800-2023 38.15). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get_value_integer_time."

static const char *format_name(PLI_INT32 f)
{
    return f == vpiIntVal ? "vpiIntVal" : f == vpiTimeVal ? "vpiTimeVal"
           : f == vpiVectorVal ? "vpiVectorVal" : f == vpiObjTypeVal ? "vpiObjTypeVal"
           : "another";
}

static void show_time(const char *what, const s_vpi_time *t)
{
    vpi_printf((PLI_BYTE8 *)"%s, time type %s, high %u low %u\n", what,
               t->type == vpiSimTime ? "vpiSimTime" : "another", (unsigned)t->high,
               (unsigned)t->low);
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    vpiHandle i = vpi_handle_by_name((PLI_BYTE8 *)TOP "i", NULL);
    vpiHandle t = vpi_handle_by_name((PLI_BYTE8 *)TOP "t", NULL);
    s_vpi_value v;

    (void)cb;
    if (i == NULL || t == NULL) {
        vpi_printf((PLI_BYTE8 *)"objects not found\n");
        return 0;
    }
    v.format = vpiObjTypeVal;
    vpi_get_value(i, &v);
    if (v.format == vpiIntVal)
        vpi_printf((PLI_BYTE8 *)"i vpiObjTypeVal: format vpiIntVal, integer %d\n",
                   (int)v.value.integer);
    else
        vpi_printf((PLI_BYTE8 *)"i vpiObjTypeVal: format %s\n", format_name(v.format));
    v.format = vpiObjTypeVal;
    vpi_get_value(t, &v);
    if (v.format == vpiTimeVal)
        show_time("t vpiObjTypeVal: format vpiTimeVal", v.value.time);
    else
        vpi_printf((PLI_BYTE8 *)"t vpiObjTypeVal: format %s\n", format_name(v.format));
    v.format = vpiTimeVal;
    vpi_get_value(t, &v);
    vpi_printf((PLI_BYTE8 *)"t vpiTimeVal: high %u low %u\n", (unsigned)v.value.time->high,
               (unsigned)v.value.time->low);
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
