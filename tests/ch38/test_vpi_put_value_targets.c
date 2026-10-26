/* VPI application of test_vpi_put_value_targets (IEEE 1800-2023 38.34). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_targets"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void put_int(vpiHandle obj, PLI_INT32 number)
{
    s_vpi_value value;

    memset(&value, 0, sizeof value);
    value.format = vpiIntVal;
    value.value.integer = number;
    vpi_put_value(obj, &value, NULL, vpiNoDelay);
}

static PLI_INT32 function_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value value;

    (void)user_data;
    memset(&value, 0, sizeof value);
    value.format = vpiIntVal;
    value.value.integer = 77;
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &value, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 put_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mem = by_name("mem");
    vpiHandle n = by_name("n");
    vpiHandle nb = by_name("nb");
    s_vpi_value scalar;

    (void)user_data;
    if (mem == NULL || n == NULL || nb == NULL) {
        vpi_printf("object not found\n");
        return 0;
    }
    put_int(by_name("v"), 11);
    put_int(vpi_handle_by_index(mem, 0), 22);
    put_int(vpi_handle_by_index(mem, 1), 33);
    vpi_put_value(by_name("ev"), NULL, NULL, vpiNoDelay);
    put_int(n, 0xa5);
    memset(&scalar, 0, sizeof scalar);
    scalar.format = vpiScalarVal;
    scalar.value.scalar = vpi1;
    vpi_put_value(vpi_handle_by_index(nb, 3), &scalar, NULL, vpiNoDelay);
    vpi_printf("errors %d\n", vpi_chk_error(NULL) != 0 ? 1 : 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_put";
    d.calltf = put_calltf;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)"$vt_value";
    d.calltf = function_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
