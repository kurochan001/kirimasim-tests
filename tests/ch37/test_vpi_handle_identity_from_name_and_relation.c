/* VPI application of test_vpi_handle_identity_from_name_and_relation (IEEE 1800-2023 37.2, 37.3.1). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_handle_identity_from_name_and_relation"

static vpiHandle by_name(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static PLI_INT32 handles_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle w1 = by_name("w");
    vpiHandle w2 = top ? vpi_handle_by_name((PLI_BYTE8 *)"w", top) : NULL;
    vpiHandle v = by_name("v");
    vpiHandle it = top ? vpi_iterate(vpiReg, top) : NULL;
    vpiHandle net, w3 = NULL;
    PLI_BYTE8 *name;

    (void)user_data;
    while (it != NULL && (net = vpi_scan(it)) != NULL) {
        name = vpi_get_str(vpiName, net);
        if (name != NULL && strcmp((const char *)name, "w") == 0)
            w3 = net;
    }
    vpi_printf((PLI_BYTE8 *)"lookups compare equal: %d\n",
               w1 != NULL && w2 != NULL && vpi_compare_objects(w1, w2));
    vpi_printf((PLI_BYTE8 *)"w and v distinct: %d\n",
               w1 != NULL && v != NULL && !vpi_compare_objects(w1, v));
    vpi_printf((PLI_BYTE8 *)"w type is variable: %d\n", vpi_get(vpiType, w1) == vpiReg);
    vpi_printf((PLI_BYTE8 *)"v type is variable: %d\n", vpi_get(vpiType, v) == vpiReg);
    vpi_printf((PLI_BYTE8 *)"w name is w: %d\n",
               w3 != NULL && strcmp((const char *)vpi_get_str(vpiName, w1), "w") == 0);
    vpi_printf((PLI_BYTE8 *)"iteration and name give the same object: %d\n",
               w3 != NULL && vpi_compare_objects(w1, w3));
    vpi_printf((PLI_BYTE8 *)"w size is 1: %d\n", vpi_get(vpiSize, w1) == 1);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_handles";
    d.calltf = handles_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
