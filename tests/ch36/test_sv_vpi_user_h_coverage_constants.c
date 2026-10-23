/* VPI application of test_sv_vpi_user_h_coverage_constants (IEEE 1800-2023 36.7, M.2). */
#include <limits.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Each constant prints only if the header defines it, so a missing
   constant is a missing line rather than a compile error. The value
   initializes an enumerator, which has to be an integer constant
   expression: a constant defined as a floating-point number or as
   anything else that is not an integer constant does not compile.
   A value outside the range of int, such as 0xFFFFFFFF, divides by
   zero in vt_in_int and does not compile either, so the printed int
   is the value itself. */
#define SHOW(c) \
    do { \
        enum { vt_value = (c), \
               vt_in_int = 1 / (((c) >= INT_MIN && (c) <= INT_MAX) ? 1 : 0) }; \
        (void)vt_in_int; \
        vpi_printf((PLI_BYTE8 *)"%s %d\n", #c, (int)vt_value); \
    } while (0)

static PLI_INT32 show_all(p_cb_data data)
{
    (void)data;
#ifdef vpiCoverageStart
    SHOW(vpiCoverageStart);
#endif
#ifdef vpiCoverageStop
    SHOW(vpiCoverageStop);
#endif
#ifdef vpiCoverageReset
    SHOW(vpiCoverageReset);
#endif
#ifdef vpiCoverageCheck
    SHOW(vpiCoverageCheck);
#endif
#ifdef vpiCoverageMerge
    SHOW(vpiCoverageMerge);
#endif
#ifdef vpiCoverageSave
    SHOW(vpiCoverageSave);
#endif
#ifdef vpiAssertCoverage
    SHOW(vpiAssertCoverage);
#endif
#ifdef vpiFsmStateCoverage
    SHOW(vpiFsmStateCoverage);
#endif
#ifdef vpiStatementCoverage
    SHOW(vpiStatementCoverage);
#endif
#ifdef vpiToggleCoverage
    SHOW(vpiToggleCoverage);
#endif
#ifdef vpiCovered
    SHOW(vpiCovered);
#endif
#ifdef vpiCoverMax
    SHOW(vpiCoverMax);
#endif
#ifdef vpiCoveredMax
    SHOW(vpiCoveredMax);
#endif
#ifdef vpiCoveredCount
    SHOW(vpiCoveredCount);
#endif
#ifdef vpiAssertAttemptCovered
    SHOW(vpiAssertAttemptCovered);
#endif
#ifdef vpiAssertSuccessCovered
    SHOW(vpiAssertSuccessCovered);
#endif
#ifdef vpiAssertFailureCovered
    SHOW(vpiAssertFailureCovered);
#endif
#ifdef vpiAssertVacuousSuccessCovered
    SHOW(vpiAssertVacuousSuccessCovered);
#endif
#ifdef vpiAssertDisableCovered
    SHOW(vpiAssertDisableCovered);
#endif
#ifdef vpiAssertKillCovered
    SHOW(vpiAssertKillCovered);
#endif
#ifdef vpiFsmStates
    SHOW(vpiFsmStates);
#endif
#ifdef vpiFsmStateExpression
    SHOW(vpiFsmStateExpression);
#endif
#ifdef vpiFsm
    SHOW(vpiFsm);
#endif
#ifdef vpiFsmHandle
    SHOW(vpiFsmHandle);
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
