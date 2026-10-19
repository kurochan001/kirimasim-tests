/* VPI application of test_vpi_userdata_per_call (IEEE 1800-2023 38.33, 38.14). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 tick_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    int *count = (int *)vpi_get_userdata(call);
    s_vpi_value v;

    if (count == NULL) {
        count = (int *)calloc(1, sizeof *count);
        vpi_put_userdata(call, count);
    }
    ++*count;
    v.format = vpiStringVal;
    vpi_get_value(vpi_scan(it), &v);
    vpi_free_object(it);
    vpi_printf("%s: run %d of this call, user_data \"%s\"\n", v.value.str, *count, user_data);
    return 0;
}

static void register_all(void)
{
{
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.sysfunctype = 0;
        d.tfname = (PLI_BYTE8 *)"$vt_tick";
        d.calltf = tick_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)"ticks";
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
