/* VPI application of test_vpi_intermod_path_delays (IEEE 1800-2023 37.37). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_intermod_path_delays"

static vpiHandle first_port(const char *instance)
{
    vpiHandle inst = vpi_handle_by_name((PLI_BYTE8 *)instance, NULL);
    vpiHandle it = inst ? vpi_iterate(vpiPort, inst) : NULL;
    vpiHandle port = it ? vpi_scan(it) : NULL;

    if (port != NULL)
        vpi_free_object(it);
    return port;
}

static void put(vpiHandle path, int n, const double *values)
{
    s_vpi_time t[3];
    s_vpi_delay d;
    int i;

    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    for (i = 0; i < n; i++) {
        t[i].type = vpiScaledRealTime;
        t[i].real = values[i];
    }
    d.da = t;
    d.no_of_delays = n;
    d.time_type = vpiScaledRealTime;
    vpi_put_delays(path, &d);
}

static void get(vpiHandle path, int n, const char *label)
{
    s_vpi_time t[3];
    s_vpi_delay d;
    int i;

    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    for (i = 0; i < n; i++)
        t[i].real = -1.0;
    d.da = t;
    d.no_of_delays = n;
    d.time_type = vpiScaledRealTime;
    vpi_get_delays(path, &d);
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %g", t[i].real);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 path_calltf(PLI_BYTE8 *user_data)
{
    static const double two[2] = {4.0, 6.0};
    static const double three[3] = {1.0, 2.0, 5.0};
    vpiHandle out = first_port(TOP ".s");
    vpiHandle in = first_port(TOP ".d");
    vpiHandle path;

    (void)user_data;
    if (out == NULL || in == NULL) {
        vpi_printf((PLI_BYTE8 *)"ports not found\n");
        return 0;
    }
    path = vpi_handle_multi(vpiInterModPath, out, in);
    vpi_printf((PLI_BYTE8 *)"intermodule path: %s\n", path == NULL ? "NULL"
               : vpi_get(vpiType, path) == vpiInterModPath ? "vpiInterModPath" : "other type");
    if (path == NULL)
        return 0;
    put(path, 2, two);
    get(path, 2, "after putting 4 6, two delays");
    put(path, 3, three);
    get(path, 3, "after putting 1 2 5, three delays");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data s;
    memset(&s, 0, sizeof s);
    s.type = vpiSysTask;
    s.tfname = (PLI_BYTE8 *)"$vt_path";
    s.calltf = path_calltf;
    vpi_register_systf(&s);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
