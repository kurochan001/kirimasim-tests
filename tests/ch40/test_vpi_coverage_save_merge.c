/* VPI application of test_vpi_coverage_save_merge (IEEE 1800-2023 40.5.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* $vt_cov_save(name) and $vt_cov_merge(name) call vpi_control with
   vpiCoverageSave or vpiCoverageMerge, vpiToggleCoverage and the name, and
   return what vpi_control returns (38.4: 1 on success, 0 on failure). */
static PLI_INT32 control_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = call ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    PLI_INT32 operation = strcmp(user_data, "save") == 0 ? vpiCoverageSave : vpiCoverageMerge;
    char name[128];
    s_vpi_value v;
    int result = 0;

    if (arg != NULL) {
        vpi_free_object(it);
        v.format = vpiStringVal;
        vpi_get_value(arg, &v);
        strncpy(name, v.value.str, sizeof name - 1);
        name[sizeof name - 1] = '\0';
        result = vpi_control(operation, vpiToggleCoverage, name);
    }
    v.format = vpiIntVal;
    v.value.integer = result;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static void register_one(const char *tfname, const char *operation)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)tfname;
    d.calltf = control_calltf;
    d.user_data = (PLI_BYTE8 *)operation;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    register_one("$vt_cov_save", "save");
    register_one("$vt_cov_merge", "merge");
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
