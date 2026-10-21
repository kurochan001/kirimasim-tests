/* VPI application of test_vpi_assertion_procedural_queue (IEEE 1800-2023 39.5.3). */
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
    case vpiAssert: return "assert";
    case vpiAssume: return "assume";
    case vpiCover: return "cover";
    default: return "other type";
    }
}

static PLI_INT32 control_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiAssertion, NULL), h;
    vpiHandle p_reset = NULL, p_disable = NULL;

    (void)user_data;
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *name = vpi_get_str(vpiName, h);
        if (name && strcmp(name, "p_reset") == 0)
            p_reset = h;
        else if (name && strcmp(name, "p_disable") == 0)
            p_disable = h;
    }
    vpi_printf("p_reset: %s\n", p_reset ? type_name(p_reset) : "not found");
    vpi_printf("p_disable: %s\n", p_disable ? type_name(p_disable) : "not found");
    if (p_reset)
        vpi_control(vpiAssertionReset, p_reset);
    if (p_disable)
        vpi_control(vpiAssertionDisable, p_disable);
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
