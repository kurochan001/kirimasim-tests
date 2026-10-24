/* VPI application of test_vpi_coverage_extension_constants (IEEE 1800-2023 40.5.1, M.2). */
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* SHOW prints a constant only when the header defines it; the value goes
   through an enumerator, so it has to be an integer constant expression. */
#define SHOW(group, c) \
    do { \
        enum { vt_value = (c) }; \
        vpi_printf((PLI_BYTE8 *)"%s %s %d\n", group, #c, (int)vt_value); \
    } while (0)

/* 1 when the n values are all different. */
static int distinct(const int *v, int n)
{
    int i, j;
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (v[i] == v[j])
                return 0;
    return 1;
}

static PLI_INT32 show_all(p_cb_data data)
{
    (void)data;
    (void)distinct; /* unused when the header lacks some constants */
#ifdef vpiCoverageStart
    SHOW("coverage control", vpiCoverageStart);
#endif
#ifdef vpiCoverageStop
    SHOW("coverage control", vpiCoverageStop);
#endif
#ifdef vpiCoverageReset
    SHOW("coverage control", vpiCoverageReset);
#endif
#ifdef vpiCoverageCheck
    SHOW("coverage control", vpiCoverageCheck);
#endif
#ifdef vpiCoverageMerge
    SHOW("coverage control", vpiCoverageMerge);
#endif
#ifdef vpiCoverageSave
    SHOW("coverage control", vpiCoverageSave);
#endif
#ifdef vpiAssertCoverage
    SHOW("coverage type", vpiAssertCoverage);
#endif
#ifdef vpiFsmStateCoverage
    SHOW("coverage type", vpiFsmStateCoverage);
#endif
#ifdef vpiStatementCoverage
    SHOW("coverage type", vpiStatementCoverage);
#endif
#ifdef vpiToggleCoverage
    SHOW("coverage type", vpiToggleCoverage);
#endif
#ifdef vpiCovered
    SHOW("coverage status", vpiCovered);
#endif
#ifdef vpiCoveredCount
    SHOW("coverage status", vpiCoveredCount);
#endif
#ifdef vpiAssertAttemptCovered
    SHOW("assertion coverage status", vpiAssertAttemptCovered);
#endif
#ifdef vpiAssertSuccessCovered
    SHOW("assertion coverage status", vpiAssertSuccessCovered);
#endif
#ifdef vpiAssertFailureCovered
    SHOW("assertion coverage status", vpiAssertFailureCovered);
#endif
#ifdef vpiAssertVacuousSuccessCovered
    SHOW("assertion coverage status", vpiAssertVacuousSuccessCovered);
#endif
#ifdef vpiAssertDisableCovered
    SHOW("assertion coverage status", vpiAssertDisableCovered);
#endif
#ifdef vpiAssertKillCovered
    SHOW("assertion coverage status", vpiAssertKillCovered);
#endif
#ifdef vpiFsmHandle
    SHOW("FSM handle type", vpiFsmHandle);
#endif
#if defined(vpiCoverageStart) && defined(vpiCoverageStop) && defined(vpiCoverageReset) && \
    defined(vpiCoverageCheck) && defined(vpiCoverageMerge) && defined(vpiCoverageSave)
    {
        static const int v[] = {vpiCoverageStart, vpiCoverageStop, vpiCoverageReset,
                                vpiCoverageCheck, vpiCoverageMerge, vpiCoverageSave};
        vpi_printf((PLI_BYTE8 *)"coverage controls distinct: %d\n", distinct(v, 6));
    }
#endif
#if defined(vpiAssertCoverage) && defined(vpiFsmStateCoverage) && \
    defined(vpiStatementCoverage) && defined(vpiToggleCoverage) && defined(vpiCovered) && \
    defined(vpiCoveredCount) && defined(vpiAssertAttemptCovered) && \
    defined(vpiAssertSuccessCovered) && defined(vpiAssertFailureCovered) && \
    defined(vpiAssertVacuousSuccessCovered) && defined(vpiAssertDisableCovered) && \
    defined(vpiAssertKillCovered)
    {
        /* All of these are properties that vpi_get takes, so they differ. */
        static const int v[] = {vpiAssertCoverage, vpiFsmStateCoverage, vpiStatementCoverage,
                                vpiToggleCoverage, vpiCovered, vpiCoveredCount,
                                vpiAssertAttemptCovered, vpiAssertSuccessCovered,
                                vpiAssertFailureCovered, vpiAssertVacuousSuccessCovered,
                                vpiAssertDisableCovered, vpiAssertKillCovered};
        vpi_printf((PLI_BYTE8 *)"coverage properties distinct: %d\n", distinct(v, 12));
    }
#endif
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = show_all;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
