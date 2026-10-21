/* VPI application of test_vpi_systf_in_generate (IEEE 1800-2023 36.4, 27.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 note_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    (void)user_data;
    if (it)
        vpi_free_object(it);
    if (arg == NULL) {
        vpi_printf("note without an argument\n");
        return 0;
    }
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    vpi_printf("note %d\n", (int)v.value.integer);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_note";
    d.calltf = note_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
