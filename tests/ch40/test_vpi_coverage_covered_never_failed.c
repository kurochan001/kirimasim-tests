/* VPI application of test_vpi_coverage_covered_never_failed (IEEE 1800-2023 40.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_coverage_covered_never_failed"

static int prop(vpiHandle h, int p)
{
    return h == NULL ? 0 : (int)vpi_get(p, h);
}

/* $vt_cov(start_result): start_result is what $coverage_control gave for the
   start of assertion coverage; the counts are checked only when it is
   SV_COV_OK (1), and it must not be SV_COV_ERROR (-1). */
static PLI_INT32 coverage_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = call ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    vpiHandle pass, mixed;
    s_vpi_value v;
    int start_result = -1, collected;

    (void)user_data;
    if (arg != NULL) {
        vpi_free_object(it);
        v.format = vpiIntVal;
        vpi_get_value(arg, &v);
        start_result = v.value.integer;
    }
    collected = start_result == 1;
    pass = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a_pass", NULL);
    mixed = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a_mixed", NULL);

    vpi_printf("assertion coverage start is not ERROR: %d\n", start_result != -1);
    vpi_printf("both assertions are found: %d\n", pass != NULL && mixed != NULL);
    vpi_printf("a_mixed: 4 attempts, 2 successes and 2 failures: %d\n",
               !collected || (prop(mixed, vpiAssertAttemptCovered) == 4
                              && prop(mixed, vpiAssertSuccessCovered) == 2
                              && prop(mixed, vpiAssertFailureCovered) == 2));
    vpi_printf("a_mixed: not covered, as it has failed: %d\n",
               !collected || prop(mixed, vpiCovered) == 0);
    vpi_printf("a_pass: covered, as it succeeded and never failed: %d\n",
               !collected || prop(pass, vpiCovered) != 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_cov";
    d.calltf = coverage_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
