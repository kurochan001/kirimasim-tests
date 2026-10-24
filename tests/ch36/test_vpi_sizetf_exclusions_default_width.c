/* VPI application of test_vpi_sizetf_exclusions_default_width (IEEE 1800-2023 36.8.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int task_sizetf_calls, real_sizetf_calls;

static PLI_INT32 task_sizetf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    task_sizetf_calls++;
    return 16;
}

static PLI_INT32 real_sizetf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    real_sizetf_calls++;
    return 16;
}

static PLI_INT32 wide_sizetf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 40;
}

static PLI_INT32 nothing_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 0;
}

static PLI_INT32 real_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;

    (void)user_data;
    v.format = vpiRealVal;
    v.value.real = 2.5;
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    return 0;
}

/* Puts the 40-bit value 40'h12_3456_789a as the result of the call. */
static PLI_INT32 forty_bit_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;
    s_vpi_vecval bits[2];

    (void)user_data;
    bits[0].aval = 0x3456789a;
    bits[0].bval = 0;
    bits[1].aval = 0x12;
    bits[1].bval = 0;
    v.format = vpiVectorVal;
    v.value.vector = bits;
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"sizetf calls: $vt_task %d, $vt_real %d\n", task_sizetf_calls,
               real_sizetf_calls);
    return 0;
}

static void add(PLI_INT32 type, PLI_INT32 functype, const char *name,
                PLI_INT32 (*calltf)(PLI_BYTE8 *), PLI_INT32 (*sizetf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = type;
    d.sysfunctype = functype;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    d.sizetf = sizetf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add(vpiSysTask, 0, "$vt_task", nothing_calltf, task_sizetf);
    add(vpiSysFunc, vpiRealFunc, "$vt_real", real_calltf, real_sizetf);
    add(vpiSysFunc, vpiSizedFunc, "$vt_wide", forty_bit_calltf, wide_sizetf);
    add(vpiSysFunc, vpiSizedFunc, "$vt_nosize", forty_bit_calltf, NULL);
    add(vpiSysTask, 0, "$vt_report", report_calltf, NULL);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
