/* VPI application of test_sv_vpi_user_h_operator_constants (IEEE 1800-2023 36.7, M.2). */
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
#ifdef vpiImplyOp
    SHOW(vpiImplyOp);
#endif
#ifdef vpiNonOverlapImplyOp
    SHOW(vpiNonOverlapImplyOp);
#endif
#ifdef vpiOverlapImplyOp
    SHOW(vpiOverlapImplyOp);
#endif
#ifdef vpiAcceptOnOp
    SHOW(vpiAcceptOnOp);
#endif
#ifdef vpiRejectOnOp
    SHOW(vpiRejectOnOp);
#endif
#ifdef vpiSyncAcceptOnOp
    SHOW(vpiSyncAcceptOnOp);
#endif
#ifdef vpiSyncRejectOnOp
    SHOW(vpiSyncRejectOnOp);
#endif
#ifdef vpiOverlapFollowedByOp
    SHOW(vpiOverlapFollowedByOp);
#endif
#ifdef vpiNonOverlapFollowedByOp
    SHOW(vpiNonOverlapFollowedByOp);
#endif
#ifdef vpiNexttimeOp
    SHOW(vpiNexttimeOp);
#endif
#ifdef vpiAlwaysOp
    SHOW(vpiAlwaysOp);
#endif
#ifdef vpiEventuallyOp
    SHOW(vpiEventuallyOp);
#endif
#ifdef vpiUntilOp
    SHOW(vpiUntilOp);
#endif
#ifdef vpiUntilWithOp
    SHOW(vpiUntilWithOp);
#endif
#ifdef vpiUnaryCycleDelayOp
    SHOW(vpiUnaryCycleDelayOp);
#endif
#ifdef vpiCycleDelayOp
    SHOW(vpiCycleDelayOp);
#endif
#ifdef vpiIntersectOp
    SHOW(vpiIntersectOp);
#endif
#ifdef vpiFirstMatchOp
    SHOW(vpiFirstMatchOp);
#endif
#ifdef vpiThroughoutOp
    SHOW(vpiThroughoutOp);
#endif
#ifdef vpiWithinOp
    SHOW(vpiWithinOp);
#endif
#ifdef vpiRepeatOp
    SHOW(vpiRepeatOp);
#endif
#ifdef vpiConsecutiveRepeatOp
    SHOW(vpiConsecutiveRepeatOp);
#endif
#ifdef vpiGotoRepeatOp
    SHOW(vpiGotoRepeatOp);
#endif
#ifdef vpiPostIncOp
    SHOW(vpiPostIncOp);
#endif
#ifdef vpiPreIncOp
    SHOW(vpiPreIncOp);
#endif
#ifdef vpiPostDecOp
    SHOW(vpiPostDecOp);
#endif
#ifdef vpiPreDecOp
    SHOW(vpiPreDecOp);
#endif
#ifdef vpiMatchOp
    SHOW(vpiMatchOp);
#endif
#ifdef vpiCastOp
    SHOW(vpiCastOp);
#endif
#ifdef vpiIffOp
    SHOW(vpiIffOp);
#endif
#ifdef vpiWildEqOp
    SHOW(vpiWildEqOp);
#endif
#ifdef vpiWildNeqOp
    SHOW(vpiWildNeqOp);
#endif
#ifdef vpiStreamLROp
    SHOW(vpiStreamLROp);
#endif
#ifdef vpiStreamRLOp
    SHOW(vpiStreamRLOp);
#endif
#ifdef vpiMatchedOp
    SHOW(vpiMatchedOp);
#endif
#ifdef vpiTriggeredOp
    SHOW(vpiTriggeredOp);
#endif
#ifdef vpiAssignmentPatternOp
    SHOW(vpiAssignmentPatternOp);
#endif
#ifdef vpiMultiAssignmentPatternOp
    SHOW(vpiMultiAssignmentPatternOp);
#endif
#ifdef vpiIfOp
    SHOW(vpiIfOp);
#endif
#ifdef vpiIfElseOp
    SHOW(vpiIfElseOp);
#endif
#ifdef vpiCompAndOp
    SHOW(vpiCompAndOp);
#endif
#ifdef vpiCompOrOp
    SHOW(vpiCompOrOp);
#endif
#ifdef vpiImpliesOp
    SHOW(vpiImpliesOp);
#endif
#ifdef vpiInsideOp
    SHOW(vpiInsideOp);
#endif
#ifdef vpiTypeOp
    SHOW(vpiTypeOp);
#endif
#ifdef vpiAssignmentOp
    SHOW(vpiAssignmentOp);
#endif
#ifdef vpiOtherFunc
    SHOW(vpiOtherFunc);
#endif
#ifdef vpiValidUnknown
    SHOW(vpiValidUnknown);
#endif
#ifdef cbStartOfThread
    SHOW(cbStartOfThread);
#endif
#ifdef cbEndOfThread
    SHOW(cbEndOfThread);
#endif
#ifdef cbEnterThread
    SHOW(cbEnterThread);
#endif
#ifdef cbStartOfFrame
    SHOW(cbStartOfFrame);
#endif
#ifdef cbEndOfFrame
    SHOW(cbEndOfFrame);
#endif
#ifdef cbSizeChange
    SHOW(cbSizeChange);
#endif
#ifdef cbCreateObj
    SHOW(cbCreateObj);
#endif
#ifdef cbReclaimObj
    SHOW(cbReclaimObj);
#endif
#ifdef cbEndOfObject
    SHOW(cbEndOfObject);
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
