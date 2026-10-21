/* VPI application of test_vpi_systf_override_signed_width (IEEE 1800-2023 36.3.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* The value of the first argument of the running call, as an integer. */
static PLI_INT32 first_argument(void)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it != NULL ? vpi_scan(it) : NULL;
    s_vpi_value v;

    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    return v.value.integer;
}

static void put_result(PLI_INT32 value)
{
    s_vpi_value v;

    v.format = vpiIntVal;
    v.value.integer = value;
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
}

static PLI_INT32 unsigned_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    put_result(first_argument() + 1);
    return 0;
}

static PLI_INT32 signed_calltf(PLI_BYTE8 *user_data)
{
    PLI_INT32 low = first_argument() & 0xff;

    (void)user_data;
    put_result(low >= 128 ? low - 256 : low);
    return 0;
}

static PLI_INT32 size12(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 12;
}

static PLI_INT32 size8(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 8;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiSizedFunc;
    d.tfname = (PLI_BYTE8 *)"$unsigned";
    d.calltf = unsigned_calltf;
    d.sizetf = size12;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiSizedSignedFunc;
    d.tfname = (PLI_BYTE8 *)"$signed";
    d.calltf = signed_calltf;
    d.sizetf = size8;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
