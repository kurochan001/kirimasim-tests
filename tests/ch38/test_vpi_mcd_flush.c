/* VPI application of test_vpi_mcd_flush (IEEE 1800-2023 38.25). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_UINT32 mcd;

static PLI_INT32 write_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    mcd = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_flush.txt");
    if (mcd == 0) {
        vpi_printf("vpi_mcd_open failed\n");
        return 0;
    }
    vpi_mcd_printf(mcd, (PLI_BYTE8 *)"flushed line %d\n", 42);
    vpi_printf("vpi_mcd_flush returns %d\n", (int)vpi_mcd_flush(mcd));
    return 0;
}

static PLI_INT32 close_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (mcd != 0)
        vpi_printf("vpi_mcd_close returns %d\n", (int)vpi_mcd_close(mcd));
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
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
    add_task("$vt_write", write_calltf);
    add_task("$vt_close", close_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
