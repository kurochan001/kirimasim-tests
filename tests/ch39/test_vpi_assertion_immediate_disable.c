/* VPI application of test_vpi_assertion_immediate_disable (IEEE 1800-2023 39.5.2). */
#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 disable_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it, a, found = NULL;

    (void)user_data;
    it = vpi_iterate(vpiAssertion, NULL);
    while (it != NULL && (a = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, a) == vpiImmediateAssert) {
            found = a;
            break;
        }
    }
    if (found == NULL) {
        vpi_printf("immediate assertion not found\n");
        return 0;
    }
    vpi_control(vpiAssertionDisable, found);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_disable";
    d.calltf = disable_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
