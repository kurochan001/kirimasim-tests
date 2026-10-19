/* VPI application of test_vpi_coverage_assertion (IEEE 1800-2023 40.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_coverage_assertion"

struct expected {
    const char *name;
    int covered, attempts, successes, failures, in_progress;
};

static const struct expected table[] = {
    {"a_never", 0, 0, 0, 0, 0},
    {"a_open", 0, 4, 0, 0, 4},
    {"a_fail", 0, 4, 0, 3, 1},
    {"a_pass", 1, 4, 3, 0, 1},
};

static void check(const char *name, const char *what, int got, int want)
{
    if (got != want)
        vpi_printf("%s: %s is %d, not %d\n", name, what, got, want);
}

static PLI_INT32 coverage_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;
    int collected = 0, i;

    (void)user_data;
    if (arg != NULL) {
        vpi_free_object(it);
        v.format = vpiIntVal;
        vpi_get_value(arg, &v);
        collected = v.value.integer != 0;
    }
    for (i = 0; i < (int)(sizeof table / sizeof table[0]); i++) {
        const struct expected *e = &table[i];
        char full[64];
        vpiHandle h;
        int attempts, successes, failures, vacuous, disabled, killed;

        snprintf(full, sizeof full, "%s.%s", TOP, e->name);
        h = vpi_handle_by_name(full, NULL);
        if (h == NULL) {
            vpi_printf("%s not found\n", e->name);
            continue;
        }
        vpi_printf("%s: covered max %d\n", e->name, (int)vpi_get(vpiCoveredMax, h));
        if (!collected)
            continue;
        attempts = (int)vpi_get(vpiAssertAttemptCovered, h);
        successes = (int)vpi_get(vpiAssertSuccessCovered, h);
        failures = (int)vpi_get(vpiAssertFailureCovered, h);
        vacuous = (int)vpi_get(vpiAssertVacuousSuccessCovered, h);
        disabled = (int)vpi_get(vpiAssertDisableCovered, h);
        killed = (int)vpi_get(vpiAssertKillCovered, h);
        check(e->name, "covered", (int)vpi_get(vpiCovered, h), e->covered);
        check(e->name, "attempts", attempts, e->attempts);
        check(e->name, "successes", successes, e->successes);
        check(e->name, "failures", failures, e->failures);
        check(e->name, "vacuous successes", vacuous, 0);
        check(e->name, "disabled", disabled, 0);
        check(e->name, "killed", killed, 0);
        check(e->name, "in progress",
              attempts - (successes + vacuous + disabled + killed + failures), e->in_progress);
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_coverage";
    d.calltf = coverage_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
