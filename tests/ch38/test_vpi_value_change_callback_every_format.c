/* VPI application of test_vpi_value_change_callback_every_format (IEEE 1800-2023 38.36.1). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_value_change_callback_every_format."
#define COUNT 16

static struct entry {
    const char *name;
    PLI_INT32 format;
    int size;
} entries[COUNT] = {
    {"b4", vpiBinStrVal, 0},     {"o6", vpiOctStrVal, 0},   {"d8", vpiDecStrVal, 0},
    {"h12", vpiHexStrVal, 0},    {"s", vpiScalarVal, 0},    {"i32", vpiIntVal, 0},
    {"r", vpiRealVal, 0},        {"str", vpiStringVal, 0},  {"t64", vpiTimeVal, 0},
    {"v36", vpiVectorVal, 0},    {"sw", vpiStrengthVal, 0}, {"oi", vpiObjTypeVal, 0},
    {"ro", vpiObjTypeVal, 0},    {"ot", vpiObjTypeVal, 0},  {"ov", vpiObjTypeVal, 0},
    {"sp", vpiSuppressVal, 0}};

static s_cb_data request;
static s_vpi_time request_time;
static s_vpi_value request_values[COUNT];

static const char *format_name(PLI_INT32 f)
{
    switch (f) {
    case vpiBinStrVal: return "vpiBinStrVal";
    case vpiOctStrVal: return "vpiOctStrVal";
    case vpiDecStrVal: return "vpiDecStrVal";
    case vpiHexStrVal: return "vpiHexStrVal";
    case vpiScalarVal: return "vpiScalarVal";
    case vpiIntVal: return "vpiIntVal";
    case vpiRealVal: return "vpiRealVal";
    case vpiStringVal: return "vpiStringVal";
    case vpiVectorVal: return "vpiVectorVal";
    case vpiStrengthVal: return "vpiStrengthVal";
    case vpiTimeVal: return "vpiTimeVal";
    case vpiObjTypeVal: return "vpiObjTypeVal";
    case vpiSuppressVal: return "vpiSuppressVal";
    default: return "another format";
    }
}

static const char *scalar_name(PLI_INT32 v)
{
    return v == vpi0 ? "vpi0" : v == vpi1 ? "vpi1" : v == vpiX ? "vpiX" : v == vpiZ ? "vpiZ"
           : v == vpiH ? "vpiH" : v == vpiL ? "vpiL" : "another";
}

static const char *strength_name(PLI_INT32 s)
{
    return s == vpiSupplyDrive ? "vpiSupplyDrive" : s == vpiStrongDrive ? "vpiStrongDrive"
           : s == vpiPullDrive ? "vpiPullDrive" : s == vpiWeakDrive ? "vpiWeakDrive"
           : "another strength";
}

static void print_words(const char *label, p_vpi_vecval v, int size, int bval)
{
    int words = (size + 31) / 32, k;

    vpi_printf((PLI_BYTE8 *)" %s", label);
    for (k = 0; k < words; k++) {
        PLI_UINT32 w = bval ? v[k].bval : v[k].aval;
        int bits = size - 32 * k;
        if (bits < 32)
            vpi_printf((PLI_BYTE8 *)" %x", (unsigned)(w & ((1u << bits) - 1u)));
        else
            vpi_printf((PLI_BYTE8 *)" %08x", (unsigned)w);
    }
}

static PLI_INT32 on_change(p_cb_data cb)
{
    struct entry *e = (struct entry *)cb->user_data;
    p_vpi_value v = cb->value;

    if (e < entries || e >= entries + COUNT)
        return 0;
    if (cb->time == NULL || cb->time->type != vpiSimTime) {
        vpi_printf((PLI_BYTE8 *)"%s: no time\n", e->name);
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"%d: %s %s", (int)cb->time->low, e->name, format_name(e->format));
    if (v == NULL || v->format == vpiSuppressVal) {
        vpi_printf((PLI_BYTE8 *)", no value\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)", got %s:", format_name(v->format));
    switch (v->format) {
    case vpiBinStrVal:
    case vpiOctStrVal:
    case vpiDecStrVal:
    case vpiHexStrVal:
    case vpiStringVal:
        vpi_printf((PLI_BYTE8 *)" %s", v->value.str);
        break;
    case vpiScalarVal:
        vpi_printf((PLI_BYTE8 *)" %s", scalar_name(v->value.scalar));
        break;
    case vpiIntVal:
        vpi_printf((PLI_BYTE8 *)" %d", (int)v->value.integer);
        break;
    case vpiRealVal:
        vpi_printf((PLI_BYTE8 *)" %.2f", v->value.real);
        break;
    case vpiTimeVal:
        if (e->format == vpiObjTypeVal)
            vpi_printf((PLI_BYTE8 *)" type %s",
                       v->value.time->type == vpiSimTime ? "vpiSimTime" : "another");
        vpi_printf((PLI_BYTE8 *)" high %u low %u", (unsigned)v->value.time->high,
                   (unsigned)v->value.time->low);
        break;
    case vpiVectorVal:
        print_words("aval", v->value.vector, e->size, 0);
        print_words("bval", v->value.vector, e->size, 1);
        break;
    case vpiStrengthVal:
        vpi_printf((PLI_BYTE8 *)" logic %s, s1 %s", scalar_name(v->value.strength->logic),
                   strength_name(v->value.strength->s1));
        break;
    default:
        break;
    }
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static PLI_INT32 at_1(p_cb_data data)
{
    char full[96];
    vpiHandle h;
    int k;

    (void)data;
    request_time.type = vpiSimTime;
    for (k = 0; k < COUNT; k++) {
        strcpy(full, TOP);
        strcat(full, entries[k].name);
        h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
        if (h == NULL) {
            vpi_printf((PLI_BYTE8 *)"%s not found\n", entries[k].name);
            continue;
        }
        entries[k].size = (int)vpi_get(vpiSize, h);
        request_values[k].format = entries[k].format;
        memset(&request, 0, sizeof request);
        request.reason = cbValueChange;
        request.cb_rtn = on_change;
        request.obj = h;
        request.time = &request_time;
        request.value = &request_values[k];
        request.user_data = (PLI_BYTE8 *)&entries[k];
        if (vpi_register_cb(&request) == NULL)
            vpi_printf((PLI_BYTE8 *)"%s: not registered\n", entries[k].name);
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
