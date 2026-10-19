/* VPI application of test_vpi_assertion_deferred_queue (IEEE 1800-2023 39.5.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *type_name(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiImmediateAssert: return "immediate assert";
    case vpiImmediateAssume: return "immediate assume";
    case vpiImmediateCover: return "immediate cover";
    default: return "other type";
    }
}

static PLI_INT32 control_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiAssertion, NULL), h;
    vpiHandle d_reset = NULL, d_disable = NULL;

    (void)user_data;
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *name = vpi_get_str(vpiName, h);
        if (name && strcmp(name, "d_reset") == 0)
            d_reset = h;
        else if (name && strcmp(name, "d_disable") == 0)
            d_disable = h;
    }
    if (d_disable)
        vpi_printf("d_disable: %s\n", type_name(d_disable));
    else
        vpi_printf("d_disable not found\n");
    if (d_reset)
        vpi_printf("d_reset: %s\n", type_name(d_reset));
    else
        vpi_printf("d_reset not found\n");
    if (d_reset)
        vpi_control(vpiAssertionReset, d_reset);
    if (d_disable)
        vpi_control(vpiAssertionDisable, d_disable);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_control";
    d.calltf = control_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
