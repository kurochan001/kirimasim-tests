/* VPI application of test_vpi_interconnect_elements (IEEE 1800-2023 37.24, 6.6.8). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interconnect_elements"

static vpiHandle find(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static PLI_INT32 ic_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle g = find("g");
    vpiHandle it = g ? vpi_iterate(vpiElement, g) : NULL, row;
    int k = 0;

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"g is %s\n",
               g && vpi_get(vpiType, g) == vpiInterconnectArray
                   ? "an interconnect array" : "not found");
    while (it != NULL && (row = vpi_scan(it)) != NULL) {
        vpiHandle it2 = vpi_iterate(vpiElement, row), net;
        int nets = 0, others = 0;
        while (it2 != NULL && (net = vpi_scan(it2)) != NULL) {
            if (vpi_get(vpiType, net) == vpiInterconnectNet)
                nets++;
            else
                others++;
        }
        vpi_printf((PLI_BYTE8 *)"element %d: %s of %d interconnect nets, %d other objects\n", k++,
                   vpi_get(vpiType, row) == vpiInterconnectArray ? "interconnect array" : "other",
                   nets, others);
    }
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
    add("$vt_ic", ic_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
