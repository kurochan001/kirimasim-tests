/* VPI application of test_vpi_register_systf_array (IEEE 1800-2023 38.37.2, 38.37.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int arg_int(vpiHandle call)
{
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    return (int)v.value.integer;
}

static void give(vpiHandle call, int value)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    v.value.integer = value;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
}

static PLI_INT32 hello_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("$vt_hello, from the first startup routine\n");
    return 0;
}

static PLI_INT32 listed_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("$vt_listed, from the array\n");
    return 0;
}

static PLI_INT32 add3_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    (void)user_data;
    give(call, arg_int(call) + 3);
    return 0;
}

static PLI_INT32 twice_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    (void)user_data;
    give(call, 2 * arg_int(call));
    return 0;
}

static void register_first(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_hello";
    d.calltf = hello_calltf;
    vpi_register_systf(&d);
}

static void register_from_array(void)
{
    static s_vpi_systf_data list[] = {
        {vpiSysTask, 0, (PLI_BYTE8 *)"$vt_listed", listed_calltf, 0, 0, 0},
        {vpiSysFunc, vpiIntFunc, (PLI_BYTE8 *)"$vt_add3", add3_calltf, 0, 0, 0},
        {vpiSysFunc, vpiIntFunc, (PLI_BYTE8 *)"$vt_twice", twice_calltf, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}};
    p_vpi_systf_data p = list;

    while (p->type)
        vpi_register_systf(p++);
}

void (*vlog_startup_routines[])(void) = {register_first, register_from_array, 0};

#ifdef __cplusplus
}
#endif
