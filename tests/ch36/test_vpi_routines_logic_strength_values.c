/* VPI application of test_vpi_routines_logic_strength_values (IEEE 1800-2023 36.11, Table 36-7). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_routines_logic_strength_values"

static int int_value(vpiHandle obj)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(obj, &v);
    return (int)v.value.integer;
}

static PLI_INT32 at_one(p_cb_data data)
{
    vpiHandle r = vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL);
    vpiHandle wk = vpi_handle_by_name((PLI_BYTE8 *)TOP ".wk", NULL);
    vpiHandle fl = vpi_handle_by_name((PLI_BYTE8 *)TOP ".fl", NULL);
    s_vpi_value v;
    s_vpi_strengthval st;
    char bits[16];

    (void)data;
    if (r == NULL || wk == NULL || fl == NULL) {
        vpi_printf("objects not found\n");
        return 0;
    }
    v.format = vpiBinStrVal;
    vpi_get_value(r, &v);
    snprintf(bits, sizeof bits, "%s", v.value.str ? v.value.str : "NULL");
    vpi_printf("vpi_get_value of r: vpiBinStrVal %s, vpiIntVal %d\n", bits, int_value(r));

    v.format = vpiStrengthVal;
    vpi_get_value(wk, &v);
    vpi_printf("vpi_get_value of wk: vpiStrengthVal logic vpi0 %d, s0 vpiWeakDrive %d\n",
               v.value.strength != NULL && v.value.strength[0].logic == vpi0,
               v.value.strength != NULL && v.value.strength[0].s0 == vpiWeakDrive);

    v.format = vpiStrengthVal;
    vpi_get_value(fl, &v);
    vpi_printf("vpi_get_value of fl: vpiStrengthVal logic vpiZ %d\n",
               v.value.strength != NULL && v.value.strength[0].logic == vpiZ);

    v.format = vpiIntVal;
    v.value.integer = 90;
    vpi_put_value(r, &v, NULL, vpiNoDelay);
    vpi_printf("vpi_put_value of 90 to r, then vpi_get_value: %d\n", int_value(r));

    st.logic = vpi1;
    st.s0 = vpiPullDrive;
    st.s1 = vpiPullDrive;
    v.format = vpiStrengthVal;
    v.value.strength = &st;
    vpi_put_value(fl, &v, NULL, vpiNoDelay);
    v.format = vpiStrengthVal;
    vpi_get_value(fl, &v);
    vpi_printf("vpi_put_value of pull 1 to fl, then vpi_get_value: logic vpi1 %d, "
               "s1 vpiPullDrive %d\n",
               v.value.strength != NULL && v.value.strength[0].logic == vpi1,
               v.value.strength != NULL && v.value.strength[0].s1 == vpiPullDrive);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    s_cb_data d;

    (void)data;
    one.type = vpiSimTime;
    one.high = 0;
    one.low = 1;
    memset(&d, 0, sizeof d);
    d.reason = cbAfterDelay;
    d.cb_rtn = at_one;
    d.time = &one;
    vpi_register_cb(&d);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
