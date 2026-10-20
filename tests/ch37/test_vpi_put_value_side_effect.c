/* VPI application of test_vpi_put_value_side_effect (IEEE 1800-2023 37.3.5, 38.34). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_side_effect"

static int calls;

static PLI_INT32 put_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;
    s_vpi_error_info info;

    (void)user_data;
    calls++;
    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiIntVal;
    v.value.integer = 5;
    vpi_chk_error(NULL);
    vpi_put_value(arg, &v, NULL, vpiNoDelay);
    vpi_printf((PLI_BYTE8 *)"argument %d: error %d\n", calls, vpi_chk_error(&info) != 0);
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_put", put_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
