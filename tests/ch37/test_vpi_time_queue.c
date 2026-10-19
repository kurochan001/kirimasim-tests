/* VPI application of test_vpi_time_queue (IEEE 1800-2023 37.81). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 queue_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_time now, t;
    vpiHandle it, q;

    (void)user_data;
    now.type = vpiSimTime;
    vpi_get_time(NULL, &now);
    vpi_printf((PLI_BYTE8 *)"%u: later times:", (unsigned)now.low);
    it = vpi_iterate(vpiTimeQueue, NULL);
    if (it != NULL)
        while ((q = vpi_scan(it)) != NULL) {
            t.type = vpiSimTime;
            vpi_get_time(q, &t);
            if (t.high > now.high || (t.high == now.high && t.low > now.low))
                vpi_printf((PLI_BYTE8 *)" %u", (unsigned)t.low);
        }
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_queue";
    d.calltf = queue_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
