/* VPI application of test_vpi_coverage_instance_control (IEEE 1800-2023 40.5.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* $vt_cov_ctl(op, target): calls vpi_control with vpiCoverageReset (op
   "reset") or vpiCoverageStop (op "stop") for the toggle coverage of the
   instance whose full name is target. */
static PLI_INT32 ctl_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle a_op = it ? vpi_scan(it) : NULL;
    vpiHandle a_target = a_op ? vpi_scan(it) : NULL;
    char op[16], target[128];
    s_vpi_value v;

    (void)user_data;
    if (a_target != NULL) {
        vpi_free_object(it);
        v.format = vpiStringVal;
        vpi_get_value(a_op, &v);
        strncpy(op, v.value.str, sizeof op - 1);
        op[sizeof op - 1] = '\0';
        v.format = vpiStringVal;
        vpi_get_value(a_target, &v);
        strncpy(target, v.value.str, sizeof target - 1);
        target[sizeof target - 1] = '\0';
        if (strcmp(op, "reset") == 0 || strcmp(op, "stop") == 0) {
            vpiHandle inst = vpi_handle_by_name(target, NULL);
            if (inst != NULL)
                vpi_control(strcmp(op, "reset") == 0 ? vpiCoverageReset : vpiCoverageStop,
                            vpiToggleCoverage, inst);
        }
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_cov_ctl";
    d.calltf = ctl_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
