/* VPI application of test_vpi_get_value_strength (IEEE 1800-2023 38.15). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get_value_strength."

static const char *logic_name(PLI_INT32 l)
{
    return l == vpi0 ? "vpi0" : l == vpi1 ? "vpi1" : l == vpiX ? "vpiX" : l == vpiZ ? "vpiZ"
           : "another";
}

static const char *strength_name(PLI_INT32 s)
{
    return s == vpiSupplyDrive ? "vpiSupplyDrive" : s == vpiStrongDrive ? "vpiStrongDrive"
           : s == vpiPullDrive ? "vpiPullDrive" : s == vpiWeakDrive ? "vpiWeakDrive"
           : s == vpiHiZ ? "vpiHiZ" : "another";
}

static p_vpi_strengthval strength_of(const char *name)
{
    char full[96];
    vpiHandle h;
    s_vpi_value v;

    strcpy(full, TOP);
    strcat(full, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        return NULL;
    v.format = vpiStrengthVal;
    vpi_get_value(h, &v);
    return v.value.strength;
}

static void show(const char *name)
{
    p_vpi_strengthval s = strength_of(name);

    if (s == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    if (s->logic == vpi1)
        vpi_printf((PLI_BYTE8 *)"%s: logic vpi1, s1 %s\n", name, strength_name(s->s1));
    else if (s->logic == vpi0)
        vpi_printf((PLI_BYTE8 *)"%s: logic vpi0, s0 %s\n", name, strength_name(s->s0));
    else
        vpi_printf((PLI_BYTE8 *)"%s: logic %s\n", name, logic_name(s->logic));
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    p_vpi_strengthval s;
    int k, strong_ones = 0, strong_zeros = 0, others = 0;

    (void)cb;
    show("wk");
    show("pl");
    show("sp");
    show("nz");
    show("nx");
    s = strength_of("rv");
    if (s == NULL) {
        vpi_printf((PLI_BYTE8 *)"rv: not found\n");
        return 0;
    }
    for (k = 0; k < 4; k++) {
        if (s[k].logic == vpi1 && s[k].s1 == vpiStrongDrive)
            strong_ones++;
        else if (s[k].logic == vpi0 && s[k].s0 == vpiStrongDrive)
            strong_zeros++;
        else
            others++;
    }
    vpi_printf((PLI_BYTE8 *)"rv: %d elements vpi1 with s1 vpiStrongDrive, %d vpi0 with s0 "
               "vpiStrongDrive, %d others\n", strong_ones, strong_zeros, others);
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
