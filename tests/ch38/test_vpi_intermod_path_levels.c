/* VPI application of test_vpi_intermod_path_levels (IEEE 1800-2023 38.22). */
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
        vpi_release_handle(it);
    return port;
}

static PLI_INT32 path_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle out = first_port("test_vpi_intermod_path_levels.m.leaf");
    vpiHandle in = first_port("test_vpi_intermod_path_levels.s");
    vpiHandle path, it, port;
    int has_out = 0, has_in = 0;

    (void)user_data;
    if (out == NULL || in == NULL) {
        vpi_printf("ports not found\n");
        return 0;
    }
    path = vpi_handle_multi(vpiInterModPath, out, in);
    vpi_printf("from m.leaf to s: %s\n", path == NULL ? "NULL"
               : vpi_get(vpiType, path) == vpiInterModPath ? "vpiInterModPath" : "other type");
    if (path == NULL)
        return 0;
    it = vpi_iterate(vpiPort, path);
    while (it != NULL && (port = vpi_scan(it)) != NULL) {
        if (vpi_compare_objects(port, out))
            has_out = 1;
        if (vpi_compare_objects(port, in))
            has_in = 1;
    }
    vpi_printf("ports of the path include the output of m.leaf: %s, the input of s: %s\n",
               has_out ? "yes" : "no", has_in ? "yes" : "no");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_path";
    d.calltf = path_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
