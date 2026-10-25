/* VPI application of test_vpi_coverage_cover_sequence (IEEE 1800-2023 40.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_coverage_cover_sequence"

static int collected = 0;
static int start_result = 0;
static int matches = 0;

static int prop(vpiHandle h, int p)
{
    return h == NULL ? 0 : (int)vpi_get(p, h);
}

static void read_arguments(void)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = call ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle first = it ? vpi_scan(it) : NULL;
    vpiHandle second = first ? vpi_scan(it) : NULL;
    s_vpi_value v;

    if (second != NULL) {
        vpi_free_object(it);
        v.format = vpiIntVal;
        vpi_get_value(first, &v);
        start_result = v.value.integer;
        collected = start_result == 1;
        v.format = vpiIntVal;
        vpi_get_value(second, &v);
        matches = v.value.integer;
    }
}

static PLI_INT32 coverage_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle h;
    int attempts, successes;

    (void)user_data;
    read_arguments();
    vpi_printf("assertion coverage start is not ERROR: %d\n", start_result != -1);
    h = vpi_handle_by_name((PLI_BYTE8 *)TOP ".c_seq", NULL);
    if (h == NULL) {
        vpi_printf("cover sequence not found\n");
        return 0;
    }
    vpi_printf("cover sequence: covered max %d\n", prop(h, vpiCoveredMax));
    attempts = prop(h, vpiAssertAttemptCovered);
    successes = prop(h, vpiAssertSuccessCovered);
    vpi_printf("cover sequence: successes are the matches: %d\n",
               !collected || (successes == matches && matches == 5));
    vpi_printf("cover sequence: one attempt has several matches: %d\n",
               !collected || (attempts == 4 && successes > attempts));
    vpi_printf("cover sequence: it is covered: %d\n",
               !collected || prop(h, vpiCovered) == 1);
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
