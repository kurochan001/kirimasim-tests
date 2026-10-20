/* VPI application of test_vpi_variable_drivers_loads (IEEE 1800-2023 37.21, 37.75). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_drivers_loads"

static vpiHandle find(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int count_type(PLI_INT32 rel, vpiHandle ref, PLI_INT32 type)
{
    vpiHandle it = vpi_iterate(rel, ref), h;
    int n = 0;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (vpi_get(vpiType, h) == type)
            n++;
    return n;
}

static PLI_INT32 dl_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle s = find("s");

    (void)user_data;
    if (s == NULL) {
        vpi_printf((PLI_BYTE8 *)"s not found\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"drivers of s: %d continuous assignments\n",
               count_type(vpiDriver, s, vpiContAssign));
    vpi_printf((PLI_BYTE8 *)"loads of s: %d continuous assignment\n",
               count_type(vpiLoad, s, vpiContAssign));
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_dl", dl_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
