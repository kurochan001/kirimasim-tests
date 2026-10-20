/* VPI application of test_vpi_handle_multi_intermod_path (IEEE 1800-2023 38.22, 37.37). */
#include <stdio.h>
#include <stdlib.h>
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

    if (port != NULL)
        vpi_free_object(it);
    return port;
}

static PLI_INT32 path_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle out = first_port("test_vpi_handle_multi_intermod_path.s");
    vpiHandle in = first_port("test_vpi_handle_multi_intermod_path.d");
    vpiHandle path;

    (void)user_data;
    if (out == NULL || in == NULL) {
        vpi_printf("ports not found\n");
        return 0;
    }
    path = vpi_handle_multi(vpiInterModPath, out, in);
    vpi_printf("intermodule path: %s\n", path == NULL ? "NULL"
               : vpi_get(vpiType, path) == vpiInterModPath ? "vpiInterModPath" : "other type");
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
