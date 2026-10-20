/* VPI application of test_vpi_coverage_control (IEEE 1800-2023 40.5.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 cov_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_coverage_control", NULL);
    s_vpi_value v;

    (void)user_data;
    if (arg == NULL || top == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiStringVal;
    vpi_get_value(arg, &v);
    if (strcmp(v.value.str, "reset") == 0)
        vpi_control(vpiCoverageReset, vpiToggleCoverage, top);
    else if (strcmp(v.value.str, "stop") == 0)
        vpi_control(vpiCoverageStop, vpiToggleCoverage, top);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_cov";
    d.calltf = cov_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
