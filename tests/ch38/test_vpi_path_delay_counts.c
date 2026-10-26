/* VPI application of test_vpi_path_delay_counts (IEEE 1800-2023 38.10, 38.32). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_path_delay_counts"

static vpiHandle path_of(const char *instance)
{
    char name[96];
    vpiHandle module, it;

    snprintf(name, sizeof name, "%s.%s", TOP, instance);
    module = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    if (module == NULL)
        return NULL;
    it = vpi_iterate(vpiModPath, module);
    return it != NULL ? vpi_scan(it) : NULL;
}

static void read_and_write(const char *instance, int count)
{
    s_vpi_time delays[12];
    s_vpi_delay d;
    vpiHandle path = path_of(instance);
    int k;

    if (path == NULL) {
        vpi_printf("%s: path not found\n", instance);
        return;
    }
    memset(delays, 0, sizeof delays);
    memset(&d, 0, sizeof d);
    d.da = delays;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(path, &d);
    vpi_printf("%s read %d:", instance, count);
    for (k = 0; k < count; k++)
        vpi_printf(" %.0f", delays[k].real);
    vpi_printf("\n");

    memset(delays, 0, sizeof delays);
    for (k = 0; k < count; k++) {
        delays[k].type = vpiScaledRealTime;
        delays[k].real = 100.0 + k;
    }
    d.da = delays;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    vpi_put_delays(path, &d);
    memset(delays, 0, sizeof delays);
    d.da = delays;
    d.no_of_delays = count;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(path, &d);
    vpi_printf("%s wrote %d:", instance, count);
    for (k = 0; k < count; k++)
        vpi_printf(" %.0f", delays[k].real);
    vpi_printf("\n");
}

static PLI_INT32 read_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    read_and_write("c1", 1);
    read_and_write("c2", 2);
    read_and_write("c3", 3);
    read_and_write("c6", 6);
    read_and_write("c12", 12);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_read";
    d.calltf = read_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
