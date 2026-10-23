/* VPI application of test_vpi_user_h_object_type_constants (IEEE 1800-2023 36.7, K.2). */
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
#ifdef vpiAlways
    SHOW(vpiAlways);
#endif
#ifdef vpiAssignStmt
    SHOW(vpiAssignStmt);
#endif
#ifdef vpiAssignment
    SHOW(vpiAssignment);
#endif
#ifdef vpiBegin
    SHOW(vpiBegin);
#endif
#ifdef vpiCase
    SHOW(vpiCase);
#endif
#ifdef vpiCaseItem
    SHOW(vpiCaseItem);
#endif
#ifdef vpiConstant
    SHOW(vpiConstant);
#endif
#ifdef vpiContAssign
    SHOW(vpiContAssign);
#endif
#ifdef vpiDeassign
    SHOW(vpiDeassign);
#endif
#ifdef vpiDefParam
    SHOW(vpiDefParam);
#endif
#ifdef vpiDelayControl
    SHOW(vpiDelayControl);
#endif
#ifdef vpiDisable
    SHOW(vpiDisable);
#endif
#ifdef vpiEventControl
    SHOW(vpiEventControl);
#endif
#ifdef vpiEventStmt
    SHOW(vpiEventStmt);
#endif
#ifdef vpiFor
    SHOW(vpiFor);
#endif
#ifdef vpiForce
    SHOW(vpiForce);
#endif
#ifdef vpiForever
    SHOW(vpiForever);
#endif
#ifdef vpiFork
    SHOW(vpiFork);
#endif
#ifdef vpiFuncCall
    SHOW(vpiFuncCall);
#endif
#ifdef vpiFunction
    SHOW(vpiFunction);
#endif
#ifdef vpiGate
    SHOW(vpiGate);
#endif
#ifdef vpiIf
    SHOW(vpiIf);
#endif
#ifdef vpiIfElse
    SHOW(vpiIfElse);
#endif
#ifdef vpiInitial
    SHOW(vpiInitial);
#endif
#ifdef vpiIntegerVar
    SHOW(vpiIntegerVar);
#endif
#ifdef vpiInterModPath
    SHOW(vpiInterModPath);
#endif
#ifdef vpiIterator
    SHOW(vpiIterator);
#endif
#ifdef vpiIODecl
    SHOW(vpiIODecl);
#endif
#ifdef vpiMemory
    SHOW(vpiMemory);
#endif
#ifdef vpiMemoryWord
    SHOW(vpiMemoryWord);
#endif
#ifdef vpiModPath
    SHOW(vpiModPath);
#endif
#ifdef vpiModule
    SHOW(vpiModule);
#endif
#ifdef vpiNamedBegin
    SHOW(vpiNamedBegin);
#endif
#ifdef vpiNamedEvent
    SHOW(vpiNamedEvent);
#endif
#ifdef vpiNamedFork
    SHOW(vpiNamedFork);
#endif
#ifdef vpiNet
    SHOW(vpiNet);
#endif
#ifdef vpiNetBit
    SHOW(vpiNetBit);
#endif
#ifdef vpiNullStmt
    SHOW(vpiNullStmt);
#endif
#ifdef vpiOperation
    SHOW(vpiOperation);
#endif
#ifdef vpiParamAssign
    SHOW(vpiParamAssign);
#endif
#ifdef vpiParameter
    SHOW(vpiParameter);
#endif
#ifdef vpiPartSelect
    SHOW(vpiPartSelect);
#endif
#ifdef vpiPathTerm
    SHOW(vpiPathTerm);
#endif
#ifdef vpiPort
    SHOW(vpiPort);
#endif
#ifdef vpiPortBit
    SHOW(vpiPortBit);
#endif
#ifdef vpiPrimTerm
    SHOW(vpiPrimTerm);
#endif
#ifdef vpiRealVar
    SHOW(vpiRealVar);
#endif
#ifdef vpiReg
    SHOW(vpiReg);
#endif
#ifdef vpiRegBit
    SHOW(vpiRegBit);
#endif
#ifdef vpiRelease
    SHOW(vpiRelease);
#endif
#ifdef vpiRepeat
    SHOW(vpiRepeat);
#endif
#ifdef vpiRepeatControl
    SHOW(vpiRepeatControl);
#endif
#ifdef vpiSchedEvent
    SHOW(vpiSchedEvent);
#endif
#ifdef vpiSpecParam
    SHOW(vpiSpecParam);
#endif
#ifdef vpiSwitch
    SHOW(vpiSwitch);
#endif
#ifdef vpiSysFuncCall
    SHOW(vpiSysFuncCall);
#endif
#ifdef vpiSysTaskCall
    SHOW(vpiSysTaskCall);
#endif
#ifdef vpiTableEntry
    SHOW(vpiTableEntry);
#endif
#ifdef vpiTask
    SHOW(vpiTask);
#endif
#ifdef vpiTaskCall
    SHOW(vpiTaskCall);
#endif
#ifdef vpiTchk
    SHOW(vpiTchk);
#endif
#ifdef vpiTchkTerm
    SHOW(vpiTchkTerm);
#endif
#ifdef vpiTimeVar
    SHOW(vpiTimeVar);
#endif
#ifdef vpiTimeQueue
    SHOW(vpiTimeQueue);
#endif
#ifdef vpiUdp
    SHOW(vpiUdp);
#endif
#ifdef vpiUdpDefn
    SHOW(vpiUdpDefn);
#endif
#ifdef vpiUserSystf
    SHOW(vpiUserSystf);
#endif
#ifdef vpiVarSelect
    SHOW(vpiVarSelect);
#endif
#ifdef vpiWait
    SHOW(vpiWait);
#endif
#ifdef vpiWhile
    SHOW(vpiWhile);
#endif
#ifdef vpiAttribute
    SHOW(vpiAttribute);
#endif
#ifdef vpiBitSelect
    SHOW(vpiBitSelect);
#endif
#ifdef vpiCallback
    SHOW(vpiCallback);
#endif
#ifdef vpiDelayTerm
    SHOW(vpiDelayTerm);
#endif
#ifdef vpiDelayDevice
    SHOW(vpiDelayDevice);
#endif
#ifdef vpiFrame
    SHOW(vpiFrame);
#endif
#ifdef vpiGateArray
    SHOW(vpiGateArray);
#endif
#ifdef vpiModuleArray
    SHOW(vpiModuleArray);
#endif
#ifdef vpiPrimitiveArray
    SHOW(vpiPrimitiveArray);
#endif
#ifdef vpiNetArray
    SHOW(vpiNetArray);
#endif
#ifdef vpiRange
    SHOW(vpiRange);
#endif
#ifdef vpiRegArray
    SHOW(vpiRegArray);
#endif
#ifdef vpiSwitchArray
    SHOW(vpiSwitchArray);
#endif
#ifdef vpiUdpArray
    SHOW(vpiUdpArray);
#endif
#ifdef vpiContAssignBit
    SHOW(vpiContAssignBit);
#endif
#ifdef vpiNamedEventArray
    SHOW(vpiNamedEventArray);
#endif
#ifdef vpiIndexedPartSelect
    SHOW(vpiIndexedPartSelect);
#endif
#ifdef vpiGenScopeArray
    SHOW(vpiGenScopeArray);
#endif
#ifdef vpiGenScope
    SHOW(vpiGenScope);
#endif
#ifdef vpiGenVar
    SHOW(vpiGenVar);
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
