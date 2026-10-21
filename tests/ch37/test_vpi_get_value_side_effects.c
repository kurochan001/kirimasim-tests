/* VPI application of test_vpi_get_value_side_effects (IEEE 1800-2023 37.3.5). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int read_int(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 twice_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = call ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    int first, second;

    (void)user_data;
    if (arg == NULL) {
        vpi_printf("no argument\n");
        return 0;
    }
    vpi_release_handle(it);
    first = read_int(arg);
    second = read_int(arg);
    vpi_printf("first read %d, second read %d\n", first, second);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_twice";
    d.calltf = twice_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
