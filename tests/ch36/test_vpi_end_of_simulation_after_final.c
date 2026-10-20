/* VPI application of test_vpi_end_of_simulation_after_final (IEEE 1800-2023 36.9.2, 9.2.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 on_end(p_cb_data data)
{
    s_vpi_time t;

    (void)data;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    vpi_printf("cbEndOfSimulation at %d\n", (int)t.low);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbEndOfSimulation;
    d.cb_rtn = on_end;
    if (vpi_register_cb(&d) == NULL)
        vpi_printf("cbEndOfSimulation not registered\n");
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
