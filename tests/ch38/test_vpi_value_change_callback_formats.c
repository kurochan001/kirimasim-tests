/* VPI application of test_vpi_value_change_callback_formats (IEEE 1800-2023 38.36.1). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_value_change_callback_formats."

/* The one structure given to vpi_register_cb for every registration. */
static s_cb_data request;
static s_vpi_time request_time;
static s_vpi_value request_values[8];
static const PLI_INT32 formats[8] = {vpiBinStrVal, vpiOctStrVal, vpiHexStrVal, vpiDecStrVal,
                                     vpiRealVal, vpiScalarVal, vpiStringVal, vpiVectorVal};
static const char *const names[8] = {"b8", "o15", "h20", "d", "r", "s", "str", "vv"};
static const char *const labels[8] = {"vpiBinStrVal", "vpiOctStrVal", "vpiHexStrVal",
                                      "vpiDecStrVal", "vpiRealVal", "vpiScalarVal",
                                      "vpiStringVal", "vpiVectorVal"};

static const char *scalar_name(PLI_INT32 v)
{
    return v == vpi0 ? "vpi0" : v == vpi1 ? "vpi1" : v == vpiX ? "vpiX" : v == vpiZ ? "vpiZ"
           : v == vpiH ? "vpiH" : v == vpiL ? "vpiL" : "another";
}

static PLI_INT32 on_change(p_cb_data cb)
{
    int k;
    const char *label = cb->user_data;
    PLI_INT32 want = 0;

    for (k = 0; k < 8; k++)
        if (strcmp(label, labels[k]) == 0)
            want = formats[k];
    if (cb->time == NULL || cb->time->type != vpiSimTime || cb->value == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no time or no value\n", label);
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"%d: %s, new structure %s, registered format %s: ",
               (int)cb->time->low, label, cb != &request ? "yes" : "no",
               cb->value->format == want ? "yes" : "no");
    switch (cb->value->format) {
    case vpiBinStrVal:
    case vpiOctStrVal:
    case vpiHexStrVal:
    case vpiDecStrVal:
    case vpiStringVal:
        vpi_printf((PLI_BYTE8 *)"%s\n", cb->value->value.str);
        break;
    case vpiRealVal:
        vpi_printf((PLI_BYTE8 *)"%.2f\n", cb->value->value.real);
        break;
    case vpiScalarVal:
        vpi_printf((PLI_BYTE8 *)"%s\n", scalar_name(cb->value->value.scalar));
        break;
    case vpiVectorVal:
        vpi_printf((PLI_BYTE8 *)"aval %08x %02x bval %08x %02x\n",
                   (unsigned)cb->value->value.vector[0].aval,
                   (unsigned)(cb->value->value.vector[1].aval & 0xff),
                   (unsigned)cb->value->value.vector[0].bval,
                   (unsigned)(cb->value->value.vector[1].bval & 0xff));
        break;
    default:
        vpi_printf((PLI_BYTE8 *)"another format\n");
    }
    return 0;
}

static PLI_INT32 at_1(p_cb_data data)
{
    char full[96];
    int k;

    (void)data;
    request_time.type = vpiSimTime;
    for (k = 0; k < 8; k++) {
        strcpy(full, TOP);
        strcat(full, names[k]);
        memset(&request, 0, sizeof request);
        request.reason = cbValueChange;
        request.cb_rtn = on_change;
        request.obj = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
        request.time = &request_time;
        request_values[k].format = formats[k];
        request.value = &request_values[k];
        request.user_data = (PLI_BYTE8 *)labels[k];
        if (request.obj == NULL || vpi_register_cb(&request) == NULL)
            vpi_printf((PLI_BYTE8 *)"%s: not registered\n", names[k]);
    }
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
