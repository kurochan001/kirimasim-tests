/* VPI application of test_vpi_systf_task_function_places (IEEE 1800-2023 36.5). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* The first argument of the current call. */
static vpiHandle first_argument(void)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it != NULL ? vpi_scan(it) : NULL;

    if (arg != NULL)
        vpi_release_handle(it);
    return arg;
}

static PLI_INT32 get_int(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    v.value.integer = 0;
    vpi_get_value(h, &v);
    return v.value.integer;
}

static void put_int(vpiHandle h, PLI_INT32 value)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    v.value.integer = value;
    vpi_put_value(h, &v, NULL, vpiNoDelay);
}

static PLI_INT32 incr_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle arg = first_argument();

    (void)user_data;
    if (arg != NULL)
        put_int(arg, get_int(arg) + 1);
    return 0;
}

static PLI_INT32 take_sizetf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 12;
}

static PLI_INT32 take_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle arg = first_argument();
    PLI_INT32 value;

    (void)user_data;
    if (arg == NULL)
        return 0;
    value = get_int(arg);
    put_int(arg, value + 100);
    put_int(vpi_handle(vpiSysTfCall, NULL), value + 0xf00);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_incr";
    d.calltf = incr_calltf;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiSizedFunc;
    d.tfname = (PLI_BYTE8 *)"$vt_take";
    d.calltf = take_calltf;
    d.sizetf = take_sizetf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
