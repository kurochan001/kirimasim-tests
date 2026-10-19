/* VPI application of test_vpi_systf_function_types (IEEE 1800-2023 36.8, 38.37). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int arg_int(vpiHandle it)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(vpi_scan(it), &v);
    return (int)v.value.integer;
}

static void put_int(vpiHandle call, int x)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    v.value.integer = x;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
}

static PLI_INT32 size8(PLI_BYTE8 *user_data) { (void)user_data; return 8; }

static PLI_INT32 sum_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    int a = arg_int(it);
    int b = arg_int(it);
    (void)user_data;
    vpi_free_object(it);
    put_int(call, a + b);
    return 0;
}

static PLI_INT32 half_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    s_vpi_value v;
    int a = arg_int(it);
    (void)user_data;
    vpi_free_object(it);
    v.format = vpiRealVal;
    v.value.real = a / 2.0;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 count_calltf(PLI_BYTE8 *user_data)
{
    static int count = 0;
    (void)user_data;
    put_int(vpi_handle(vpiSysTfCall, NULL), ++count);
    return 0;
}

static void register_all(void)
{
{
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysFunc;
        d.sysfunctype = vpiSizedFunc;
        d.tfname = (PLI_BYTE8 *)"$vt_sum8";
        d.calltf = sum_calltf;
        d.sizetf = size8;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
    {
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysFunc;
        d.sysfunctype = vpiSizedSignedFunc;
        d.tfname = (PLI_BYTE8 *)"$vt_sum8s";
        d.calltf = sum_calltf;
        d.sizetf = size8;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
    {
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysFunc;
        d.sysfunctype = vpiRealFunc;
        d.tfname = (PLI_BYTE8 *)"$vt_half";
        d.calltf = half_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
    {
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysFunc;
        d.sysfunctype = vpiIntFunc;
        d.tfname = (PLI_BYTE8 *)"$vt_count";
        d.calltf = count_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
