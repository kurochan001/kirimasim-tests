#include <stddef.h>
#include <stdio.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle get_interface_port(vpiHandle instance)
{
    vpiHandle iterator = vpi_iterate(vpiPort, instance), port;
    if (iterator == NULL)
        return NULL;
    while ((port = vpi_scan(iterator)) != NULL) {
        if (vpi_get(vpiPortType, port) == vpiInterfacePort) {
            vpi_release_handle(iterator);
            return port;
        }
    }
    return NULL;
}

static int report_error(const char *method)
{
    s_vpi_error_info error = {0};
    if (vpi_chk_error(&error) < vpiError)
        return 0;
    if (error.message != NULL)
        fprintf(stderr, "%s delays error: %s\n", method, (const char *)error.message);
    return 1;
}

static PLI_INT32 probe(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call == NULL ? NULL : vpi_handle(vpiScope, call);
    vpiHandle instance = scope == NULL ? NULL :
        vpi_handle_by_name((PLI_BYTE8 *)"instance_under_test", scope);
    (void)unused;
    if (instance == NULL)
        return 0;

    vpiHandle iterator = vpi_iterate(vpiModPath, instance);
    vpiHandle path = iterator == NULL ? NULL : vpi_scan(iterator);
    if (path == NULL)
        return 0;
    vpi_release_handle(iterator);
    vpiHandle port = get_interface_port(instance);
    if (port == NULL)
        return 0;

    s_vpi_time entry = {.type = vpiSimTime};
    s_vpi_delay delay = {.da = &entry, .no_of_delays = 1, .time_type = vpiSimTime};
    vpi_get_delays(path, &delay);
    unsigned path_delay = entry.low;
    vpi_get_delays(port, &delay);
    int bad_get = report_error("get");
    s_vpi_time replacement = {.type = vpiSimTime, .low = 5};
    s_vpi_delay put = {.da = &replacement, .no_of_delays = 1, .time_type = vpiSimTime};
    vpi_put_delays(port, &put);
    int bad_put = report_error("put");
    vpi_printf("path delay=%u interface get error=%d interface put error=%d\n",
               path_delay, bad_get, bad_put);
    return 0;
}

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_probe_delays";
    task.calltf = probe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
