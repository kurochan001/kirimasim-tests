/* VPI application of test_vpi_gate_delays (IEEE 1800-2023 38.10, 38.32). */
#include <stdio.h>
#include <stdlib.h>
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

static void show(vpiHandle g, const char *what)
{
    s_vpi_time da[2];
    s_vpi_delay d;

    memset(&d, 0, sizeof d);
    memset(da, 0, sizeof da);
    d.da = da;
    d.no_of_delays = 2;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(g, &d);
    vpi_printf("%d: %s delays %.0f %.0f\n", now(), what, da[0].real, da[1].real);
}

static PLI_INT32 delays_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle g = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_gate_delays.g1", NULL);
    s_vpi_time da[2];
    s_vpi_delay d;

    (void)user_data;
    if (g == NULL) {
        vpi_printf("g1 not found\n");
        return 0;
    }
    show(g, "old");
    memset(&d, 0, sizeof d);
    memset(da, 0, sizeof da);
    da[0].type = vpiScaledRealTime;
    da[0].real = 7.0;
    da[1].type = vpiScaledRealTime;
    da[1].real = 9.0;
    d.da = da;
    d.no_of_delays = 2;
    d.time_type = vpiScaledRealTime;
    vpi_put_delays(g, &d);
    show(g, "new");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_delays";
    d.calltf = delays_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
