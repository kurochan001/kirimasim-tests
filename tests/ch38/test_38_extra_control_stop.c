/* VPI application of test_38_extra_control_stop (IEEE 1800-2023 38.4). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int now(void)
{
    s_vpi_time t;

    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 stop_calltf(PLI_BYTE8 *user_data)
{
    PLI_INT32 result;
    int at = now();

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"%d: routine before vpi_control\n", at);
    result = vpi_control(vpiStop, 0);
    vpi_printf((PLI_BYTE8 *)"%d: vpi_control(vpiStop, 0) returned %d\n", at,
               (int)result);
    vpi_printf((PLI_BYTE8 *)"%d: the routine went on after vpi_control\n", at);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_stop";
    d.calltf = stop_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
