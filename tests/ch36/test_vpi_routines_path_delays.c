/* VPI application of test_vpi_routines_path_delays (IEEE 1800-2023 36.11, Table 36-6). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void read_delays(vpiHandle path, s_vpi_time da[2])
{
    s_vpi_delay delays;

    memset(&delays, 0, sizeof delays);
    memset(da, 0, 2 * sizeof da[0]);
    delays.da = da;
    delays.no_of_delays = 2;
    delays.time_type = vpiScaledRealTime;
    vpi_get_delays(path, &delays);
}

static PLI_INT32 at_five(p_cb_data data)
{
    vpiHandle cell = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_routines_path_delays.c", NULL);
    vpiHandle it = cell == NULL ? NULL : vpi_iterate(vpiModPath, cell), path = NULL, p;
    s_vpi_time da[2];
    s_vpi_delay delays;

    (void)data;
    while (it != NULL && (p = vpi_scan(it)) != NULL)
        if (path == NULL)
            path = p;
    if (path == NULL) {
        vpi_printf("5: no module path found\n");
        return 0;
    }
    read_delays(path, da);
    vpi_printf("5: vpi_get_delays: %g %g\n", da[0].real, da[1].real);

    memset(&delays, 0, sizeof delays);
    memset(da, 0, sizeof da);
    da[0].type = vpiScaledRealTime;
    da[0].real = 7.0;
    da[1].type = vpiScaledRealTime;
    da[1].real = 9.0;
    delays.da = da;
    delays.no_of_delays = 2;
    delays.time_type = vpiScaledRealTime;
    vpi_put_delays(path, &delays);

    read_delays(path, da);
    vpi_printf("5: vpi_put_delays: 7 9, then vpi_get_delays: %g %g\n", da[0].real, da[1].real);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time five;
    s_cb_data d;

    (void)data;
    five.type = vpiSimTime;
    five.high = 0;
    five.low = 5;
    memset(&d, 0, sizeof d);
    d.reason = cbAfterDelay;
    d.cb_rtn = at_five;
    d.time = &five;
    vpi_register_cb(&d);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
