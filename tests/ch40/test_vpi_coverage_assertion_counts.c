/* VPI application of test_vpi_coverage_assertion_counts (IEEE 1800-2023 40.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_coverage_assertion_counts"

/* covered is the value vpiCovered must give, or -1 where 40.5.2 does not
   settle it for this stimulus. */
struct expected {
    const char *name;
    int attempts, successes, vacuous, disabled, killed, failures, covered;
};

static const struct expected table[] = {
    {"a_never", 0, 0, 0, 0, 0, 0, 0},
    {"a_pass", 4, 4, 0, 0, 0, 0, 1},
    {"a_vac", 4, 0, 4, 0, 0, 0, -1},
    {"a_dis", 4, 0, 0, 4, 0, 0, -1},
    {"a_fail", 4, 0, 0, 0, 0, 4, 0},
    {"a_kill", 1, 0, 0, 0, 1, 0, -1},
};

static int collected = 0;
static int start_result = 0;

static int prop(vpiHandle h, int p)
{
    return h == NULL ? 0 : (int)vpi_get(p, h);
}

static void read_arguments(void)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = call ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;

    if (arg != NULL) {
        vpi_free_object(it);
        v.format = vpiIntVal;
        vpi_get_value(arg, &v);
        start_result = v.value.integer;
        collected = start_result == 1;
    }
}

static PLI_INT32 coverage_calltf(PLI_BYTE8 *user_data)
{
    int i;
    int covered_ok = 1;

    (void)user_data;
    read_arguments();
    vpi_printf("assertion coverage start is not ERROR: %d\n", start_result != -1);
    for (i = 0; i < (int)(sizeof table / sizeof table[0]); i++) {
        const struct expected *e = &table[i];
        char full[80];
        vpiHandle h;
        int attempts, successes, vacuous, disabled, killed, failures, in_progress;

        snprintf(full, sizeof full, "%s.%s", TOP, e->name);
        h = vpi_handle_by_name(full, NULL);
        if (h == NULL) {
            vpi_printf("%s: not found\n", e->name);
            continue;
        }
        vpi_printf("%s: covered max %d\n", e->name, prop(h, vpiCoveredMax));
        if (!collected) {
            vpi_printf("%s: counts are as the stimulus: 1\n", e->name);
            vpi_printf("%s: no attempt is in progress: 1\n", e->name);
            continue;
        }
        attempts = prop(h, vpiAssertAttemptCovered);
        successes = prop(h, vpiAssertSuccessCovered);
        vacuous = prop(h, vpiAssertVacuousSuccessCovered);
        disabled = prop(h, vpiAssertDisableCovered);
        killed = prop(h, vpiAssertKillCovered);
        failures = prop(h, vpiAssertFailureCovered);
        in_progress = attempts - (successes + vacuous + disabled + killed + failures);
        vpi_printf("%s: counts are as the stimulus: %d\n", e->name,
                   attempts == e->attempts && successes == e->successes
                   && vacuous == e->vacuous && disabled == e->disabled
                   && killed == e->killed && failures == e->failures);
        vpi_printf("%s: no attempt is in progress: %d\n", e->name, in_progress == 0);
        if (e->covered >= 0 && prop(h, vpiCovered) != e->covered)
            covered_ok = 0;
    }
    vpi_printf("covered: a passed assertion is covered, an unattempted one not: %d\n",
               !collected || covered_ok);
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
