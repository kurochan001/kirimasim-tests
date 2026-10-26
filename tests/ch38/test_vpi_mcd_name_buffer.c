/* VPI application of test_vpi_mcd_name_buffer (IEEE 1800-2023 38.26). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 name_calltf(PLI_BYTE8 *user_data)
{
    PLI_UINT32 a, b;
    PLI_BYTE8 *p, *q, *r;

    (void)user_data;
    a = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_name_buffer_a.txt");
    b = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_name_buffer_b.txt");
    if (a == 0 || b == 0) {
        vpi_printf((PLI_BYTE8 *)"open failed\n");
        return 0;
    }
    p = vpi_mcd_name(a);
    q = vpi_mcd_name(b);
    vpi_printf((PLI_BYTE8 *)"same buffer: %d\n", p == q);
    vpi_printf((PLI_BYTE8 *)"second name: %s\n", q);
    vpi_printf((PLI_BYTE8 *)"first name after the second call: %s\n", p);
    r = vpi_mcd_name(a);
    vpi_printf((PLI_BYTE8 *)"name of a: %s\n", r);
    vpi_mcd_close(a);
    vpi_printf((PLI_BYTE8 *)"closed name is NULL: %d\n",
               vpi_mcd_name(a) == NULL);
    vpi_mcd_close(b);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_name";
    d.calltf = name_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
