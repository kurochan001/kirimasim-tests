/* VPI application of test_vpi_port_kind_defaults (IEEE 1800-2023 23.2.2.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *const ports[] = {
    "in_logic", "in_int", "in_var", "io", "out_plain", "out_signed", "out_logic", "out_integer",
};

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiNet: return "logic net";
    case vpiIntNet: return "int net";
    case vpiReg: return "logic variable";
    case vpiIntegerVar: return "integer variable";
    default: return "other";
    }
}

static PLI_INT32 kinds_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    for (i = 0; i < (int)(sizeof ports / sizeof ports[0]); i++) {
        char full[64];
        vpiHandle h;
        snprintf(full, sizeof full, "test_vpi_port_kind_defaults.u.%s", ports[i]);
        h = vpi_handle_by_name(full, NULL);
        vpi_printf("%s: %s\n", ports[i], h ? kind(h) : "not found");
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_kinds";
    d.calltf = kinds_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
