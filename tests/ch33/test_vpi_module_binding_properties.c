/* VPI application of test_vpi_module_binding_properties (IEEE 1800-2023 33.7). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_module_binding_properties"

static void copy_str(char *dst, size_t size, const char *src)
{
    snprintf(dst, size, "%s", src != NULL ? src : "");
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it, m;
    int found = 0;

    (void)user_data;
    if (top == NULL) {
        vpi_printf("top not found\n");
        return 0;
    }
    it = vpi_iterate(vpiModule, top);
    while (it != NULL && (m = vpi_scan(it)) != NULL) {
        char name[64], lib[64], cell[64], config[64];
        copy_str(name, sizeof name, vpi_get_str(vpiName, m));
        copy_str(lib, sizeof lib, vpi_get_str(vpiLibrary, m));
        copy_str(cell, sizeof cell, vpi_get_str(vpiCell, m));
        copy_str(config, sizeof config, vpi_get_str(vpiConfig, m));
        if (strcmp(name, "u") != 0)
            continue;
        found = 1;
        vpi_printf("u library work: %d\n", strcmp(lib, "work") == 0);
        vpi_printf("u cell leaf: %d\n", strcmp(cell, "leaf") == 0);
        vpi_printf("u config is set: %d\n", config[0] != '\0');
    }
    if (!found)
        vpi_printf("u not found\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_report";
    d.calltf = report_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
