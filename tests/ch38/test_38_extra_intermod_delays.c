/* VPI application of test_38_extra_intermod_delays (IEEE 1800-2023 38.32, 38.10). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle first_port(const char *instance)
{
    vpiHandle inst = vpi_handle_by_name((PLI_BYTE8 *)instance, NULL);
    vpiHandle it = inst ? vpi_iterate(vpiPort, inst) : NULL;
    vpiHandle port = it ? vpi_scan(it) : NULL;

    if (it != NULL)
        vpi_free_object(it);
    return port;
}

static void round_trip(vpiHandle path, int count, double base)
{
    s_vpi_time delays[8];
    s_vpi_delay d;
    int k;

    memset(delays, 0, sizeof delays);
    for (k = 0; k < 8; k++) {
        delays[k].type = vpiScaledRealTime;
        delays[k].real = base + k;
    }
    memset(&d, 0, sizeof d);
    d.da = delays;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    vpi_put_delays(path, &d);

    memset(delays, 0, sizeof delays);
    memset(&d, 0, sizeof d);
    d.da = delays;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(path, &d);
    vpi_printf((PLI_BYTE8 *)"%d delays:", (int)d.no_of_delays);
    for (k = 0; k < d.no_of_delays && k < 8; k++)
        vpi_printf((PLI_BYTE8 *)" %.0f", delays[k].real);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 delays_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle out = first_port("test_38_extra_intermod_delays.s");
    vpiHandle in = first_port("test_38_extra_intermod_delays.d");
    vpiHandle path;

    (void)user_data;
    if (out == NULL || in == NULL) {
        vpi_printf((PLI_BYTE8 *)"ports not found\n");
        return 0;
    }
    path = vpi_handle_multi(vpiInterModPath, out, in);
    if (path == NULL) {
        vpi_printf((PLI_BYTE8 *)"path not found\n");
        return 0;
    }
    round_trip(path, 2, 7.0);
    round_trip(path, 3, 9.0);
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
