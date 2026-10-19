/* VPI application of test_vpi_mcd_files (IEEE 1800-2023 38.27, 38.28). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 write_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    s_vpi_value v;
    PLI_UINT32 mcd;

    (void)user_data;
    v.format = vpiStringVal;
    vpi_get_value(vpi_scan(it), &v);
    vpi_free_object(it);
    mcd = vpi_mcd_open(v.value.str);
    vpi_printf("opened %s\n", vpi_mcd_name(mcd));
    vpi_mcd_printf(mcd, "first line\n");
    vpi_mcd_printf(mcd | 1, "value %d\n", 42);
    vpi_mcd_close(mcd);
    return 0;
}

static void register_all(void)
{
{
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.sysfunctype = 0;
        d.tfname = (PLI_BYTE8 *)"$vt_write_file";
        d.calltf = write_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
