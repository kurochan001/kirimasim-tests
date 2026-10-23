/* VPI application of test_sv_vpi_user_h_assertion_constants (IEEE 1800-2023 36.7, M.2). */
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
#ifdef cbAssertionStart
    SHOW(cbAssertionStart);
#endif
#ifdef cbAssertionSuccess
    SHOW(cbAssertionSuccess);
#endif
#ifdef cbAssertionFailure
    SHOW(cbAssertionFailure);
#endif
#ifdef cbAssertionVacuousSuccess
    SHOW(cbAssertionVacuousSuccess);
#endif
#ifdef cbAssertionDisabledEvaluation
    SHOW(cbAssertionDisabledEvaluation);
#endif
#ifdef cbAssertionStepSuccess
    SHOW(cbAssertionStepSuccess);
#endif
#ifdef cbAssertionStepFailure
    SHOW(cbAssertionStepFailure);
#endif
#ifdef cbAssertionLock
    SHOW(cbAssertionLock);
#endif
#ifdef cbAssertionUnlock
    SHOW(cbAssertionUnlock);
#endif
#ifdef cbAssertionDisable
    SHOW(cbAssertionDisable);
#endif
#ifdef cbAssertionEnable
    SHOW(cbAssertionEnable);
#endif
#ifdef cbAssertionReset
    SHOW(cbAssertionReset);
#endif
#ifdef cbAssertionKill
    SHOW(cbAssertionKill);
#endif
#ifdef cbAssertionEnablePassAction
    SHOW(cbAssertionEnablePassAction);
#endif
#ifdef cbAssertionEnableFailAction
    SHOW(cbAssertionEnableFailAction);
#endif
#ifdef cbAssertionDisablePassAction
    SHOW(cbAssertionDisablePassAction);
#endif
#ifdef cbAssertionDisableFailAction
    SHOW(cbAssertionDisableFailAction);
#endif
#ifdef cbAssertionEnableNonvacuousAction
    SHOW(cbAssertionEnableNonvacuousAction);
#endif
#ifdef cbAssertionDisableVacuousAction
    SHOW(cbAssertionDisableVacuousAction);
#endif
#ifdef cbAssertionSysInitialized
    SHOW(cbAssertionSysInitialized);
#endif
#ifdef cbAssertionSysOn
    SHOW(cbAssertionSysOn);
#endif
#ifdef cbAssertionSysOff
    SHOW(cbAssertionSysOff);
#endif
#ifdef cbAssertionSysKill
    SHOW(cbAssertionSysKill);
#endif
#ifdef cbAssertionSysLock
    SHOW(cbAssertionSysLock);
#endif
#ifdef cbAssertionSysUnlock
    SHOW(cbAssertionSysUnlock);
#endif
#ifdef cbAssertionSysEnd
    SHOW(cbAssertionSysEnd);
#endif
#ifdef cbAssertionSysReset
    SHOW(cbAssertionSysReset);
#endif
#ifdef cbAssertionSysEnablePassAction
    SHOW(cbAssertionSysEnablePassAction);
#endif
#ifdef cbAssertionSysEnableFailAction
    SHOW(cbAssertionSysEnableFailAction);
#endif
#ifdef cbAssertionSysDisablePassAction
    SHOW(cbAssertionSysDisablePassAction);
#endif
#ifdef cbAssertionSysDisableFailAction
    SHOW(cbAssertionSysDisableFailAction);
#endif
#ifdef cbAssertionSysEnableNonvacuousAction
    SHOW(cbAssertionSysEnableNonvacuousAction);
#endif
#ifdef cbAssertionSysDisableVacuousAction
    SHOW(cbAssertionSysDisableVacuousAction);
#endif
#ifdef vpiAssertionLock
    SHOW(vpiAssertionLock);
#endif
#ifdef vpiAssertionUnlock
    SHOW(vpiAssertionUnlock);
#endif
#ifdef vpiAssertionDisable
    SHOW(vpiAssertionDisable);
#endif
#ifdef vpiAssertionEnable
    SHOW(vpiAssertionEnable);
#endif
#ifdef vpiAssertionReset
    SHOW(vpiAssertionReset);
#endif
#ifdef vpiAssertionKill
    SHOW(vpiAssertionKill);
#endif
#ifdef vpiAssertionEnableStep
    SHOW(vpiAssertionEnableStep);
#endif
#ifdef vpiAssertionDisableStep
    SHOW(vpiAssertionDisableStep);
#endif
#ifdef vpiAssertionClockSteps
    SHOW(vpiAssertionClockSteps);
#endif
#ifdef vpiAssertionSysLock
    SHOW(vpiAssertionSysLock);
#endif
#ifdef vpiAssertionSysUnlock
    SHOW(vpiAssertionSysUnlock);
#endif
#ifdef vpiAssertionSysOn
    SHOW(vpiAssertionSysOn);
#endif
#ifdef vpiAssertionSysOff
    SHOW(vpiAssertionSysOff);
#endif
#ifdef vpiAssertionSysKill
    SHOW(vpiAssertionSysKill);
#endif
#ifdef vpiAssertionSysEnd
    SHOW(vpiAssertionSysEnd);
#endif
#ifdef vpiAssertionSysReset
    SHOW(vpiAssertionSysReset);
#endif
#ifdef vpiAssertionDisablePassAction
    SHOW(vpiAssertionDisablePassAction);
#endif
#ifdef vpiAssertionEnablePassAction
    SHOW(vpiAssertionEnablePassAction);
#endif
#ifdef vpiAssertionDisableFailAction
    SHOW(vpiAssertionDisableFailAction);
#endif
#ifdef vpiAssertionEnableFailAction
    SHOW(vpiAssertionEnableFailAction);
#endif
#ifdef vpiAssertionDisableVacuousAction
    SHOW(vpiAssertionDisableVacuousAction);
#endif
#ifdef vpiAssertionEnableNonvacuousAction
    SHOW(vpiAssertionEnableNonvacuousAction);
#endif
#ifdef vpiAssertionSysEnablePassAction
    SHOW(vpiAssertionSysEnablePassAction);
#endif
#ifdef vpiAssertionSysEnableFailAction
    SHOW(vpiAssertionSysEnableFailAction);
#endif
#ifdef vpiAssertionSysDisablePassAction
    SHOW(vpiAssertionSysDisablePassAction);
#endif
#ifdef vpiAssertionSysDisableFailAction
    SHOW(vpiAssertionSysDisableFailAction);
#endif
#ifdef vpiAssertionSysEnableNonvacuousAction
    SHOW(vpiAssertionSysEnableNonvacuousAction);
#endif
#ifdef vpiAssertionSysDisableVacuousAction
    SHOW(vpiAssertionSysDisableVacuousAction);
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
