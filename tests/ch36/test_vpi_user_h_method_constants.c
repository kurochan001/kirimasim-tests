/* VPI application of test_vpi_user_h_method_constants (IEEE 1800-2023 36.7, K.2). */
#include <limits.h>
#include <string.h>
#include "vpi_user.h"

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
#ifdef vpiCondition
    SHOW(vpiCondition);
#endif
#ifdef vpiDelay
    SHOW(vpiDelay);
#endif
#ifdef vpiElseStmt
    SHOW(vpiElseStmt);
#endif
#ifdef vpiForIncStmt
    SHOW(vpiForIncStmt);
#endif
#ifdef vpiForInitStmt
    SHOW(vpiForInitStmt);
#endif
#ifdef vpiHighConn
    SHOW(vpiHighConn);
#endif
#ifdef vpiLhs
    SHOW(vpiLhs);
#endif
#ifdef vpiIndex
    SHOW(vpiIndex);
#endif
#ifdef vpiLeftRange
    SHOW(vpiLeftRange);
#endif
#ifdef vpiLowConn
    SHOW(vpiLowConn);
#endif
#ifdef vpiParent
    SHOW(vpiParent);
#endif
#ifdef vpiRhs
    SHOW(vpiRhs);
#endif
#ifdef vpiRightRange
    SHOW(vpiRightRange);
#endif
#ifdef vpiScope
    SHOW(vpiScope);
#endif
#ifdef vpiSysTfCall
    SHOW(vpiSysTfCall);
#endif
#ifdef vpiTchkDataTerm
    SHOW(vpiTchkDataTerm);
#endif
#ifdef vpiTchkNotifier
    SHOW(vpiTchkNotifier);
#endif
#ifdef vpiTchkRefTerm
    SHOW(vpiTchkRefTerm);
#endif
#ifdef vpiArgument
    SHOW(vpiArgument);
#endif
#ifdef vpiBit
    SHOW(vpiBit);
#endif
#ifdef vpiDriver
    SHOW(vpiDriver);
#endif
#ifdef vpiInternalScope
    SHOW(vpiInternalScope);
#endif
#ifdef vpiLoad
    SHOW(vpiLoad);
#endif
#ifdef vpiModDataPathIn
    SHOW(vpiModDataPathIn);
#endif
#ifdef vpiModPathIn
    SHOW(vpiModPathIn);
#endif
#ifdef vpiModPathOut
    SHOW(vpiModPathOut);
#endif
#ifdef vpiOperand
    SHOW(vpiOperand);
#endif
#ifdef vpiPortInst
    SHOW(vpiPortInst);
#endif
#ifdef vpiProcess
    SHOW(vpiProcess);
#endif
#ifdef vpiVariables
    SHOW(vpiVariables);
#endif
#ifdef vpiUse
    SHOW(vpiUse);
#endif
#ifdef vpiExpr
    SHOW(vpiExpr);
#endif
#ifdef vpiPrimitive
    SHOW(vpiPrimitive);
#endif
#ifdef vpiStmt
    SHOW(vpiStmt);
#endif
#ifdef vpiActiveTimeFormat
    SHOW(vpiActiveTimeFormat);
#endif
#ifdef vpiInTerm
    SHOW(vpiInTerm);
#endif
#ifdef vpiInstanceArray
    SHOW(vpiInstanceArray);
#endif
#ifdef vpiLocalDriver
    SHOW(vpiLocalDriver);
#endif
#ifdef vpiLocalLoad
    SHOW(vpiLocalLoad);
#endif
#ifdef vpiOutTerm
    SHOW(vpiOutTerm);
#endif
#ifdef vpiPorts
    SHOW(vpiPorts);
#endif
#ifdef vpiSimNet
    SHOW(vpiSimNet);
#endif
#ifdef vpiTaskFunc
    SHOW(vpiTaskFunc);
#endif
#ifdef vpiBaseExpr
    SHOW(vpiBaseExpr);
#endif
#ifdef vpiWidthExpr
    SHOW(vpiWidthExpr);
#endif
#ifdef vpiAutomatics
    SHOW(vpiAutomatics);
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
