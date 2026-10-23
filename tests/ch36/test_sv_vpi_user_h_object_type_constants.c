/* VPI application of test_sv_vpi_user_h_object_type_constants (IEEE 1800-2023 36.7, M.2). */
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
#ifdef vpiPackage
    SHOW(vpiPackage);
#endif
#ifdef vpiInterface
    SHOW(vpiInterface);
#endif
#ifdef vpiProgram
    SHOW(vpiProgram);
#endif
#ifdef vpiInterfaceArray
    SHOW(vpiInterfaceArray);
#endif
#ifdef vpiProgramArray
    SHOW(vpiProgramArray);
#endif
#ifdef vpiTypespec
    SHOW(vpiTypespec);
#endif
#ifdef vpiModport
    SHOW(vpiModport);
#endif
#ifdef vpiInterfaceTfDecl
    SHOW(vpiInterfaceTfDecl);
#endif
#ifdef vpiRefObj
    SHOW(vpiRefObj);
#endif
#ifdef vpiTypeParameter
    SHOW(vpiTypeParameter);
#endif
#ifdef vpiVarBit
    SHOW(vpiVarBit);
#endif
#ifdef vpiLongIntVar
    SHOW(vpiLongIntVar);
#endif
#ifdef vpiShortIntVar
    SHOW(vpiShortIntVar);
#endif
#ifdef vpiIntVar
    SHOW(vpiIntVar);
#endif
#ifdef vpiShortRealVar
    SHOW(vpiShortRealVar);
#endif
#ifdef vpiByteVar
    SHOW(vpiByteVar);
#endif
#ifdef vpiClassVar
    SHOW(vpiClassVar);
#endif
#ifdef vpiStringVar
    SHOW(vpiStringVar);
#endif
#ifdef vpiEnumVar
    SHOW(vpiEnumVar);
#endif
#ifdef vpiStructVar
    SHOW(vpiStructVar);
#endif
#ifdef vpiUnionVar
    SHOW(vpiUnionVar);
#endif
#ifdef vpiBitVar
    SHOW(vpiBitVar);
#endif
#ifdef vpiLogicVar
    SHOW(vpiLogicVar);
#endif
#ifdef vpiArrayVar
    SHOW(vpiArrayVar);
#endif
#ifdef vpiClassObj
    SHOW(vpiClassObj);
#endif
#ifdef vpiChandleVar
    SHOW(vpiChandleVar);
#endif
#ifdef vpiPackedArrayVar
    SHOW(vpiPackedArrayVar);
#endif
#ifdef vpiVirtualInterfaceVar
    SHOW(vpiVirtualInterfaceVar);
#endif
#ifdef vpiLongIntTypespec
    SHOW(vpiLongIntTypespec);
#endif
#ifdef vpiShortRealTypespec
    SHOW(vpiShortRealTypespec);
#endif
#ifdef vpiByteTypespec
    SHOW(vpiByteTypespec);
#endif
#ifdef vpiShortIntTypespec
    SHOW(vpiShortIntTypespec);
#endif
#ifdef vpiIntTypespec
    SHOW(vpiIntTypespec);
#endif
#ifdef vpiClassTypespec
    SHOW(vpiClassTypespec);
#endif
#ifdef vpiStringTypespec
    SHOW(vpiStringTypespec);
#endif
#ifdef vpiChandleTypespec
    SHOW(vpiChandleTypespec);
#endif
#ifdef vpiEnumTypespec
    SHOW(vpiEnumTypespec);
#endif
#ifdef vpiEnumConst
    SHOW(vpiEnumConst);
#endif
#ifdef vpiIntegerTypespec
    SHOW(vpiIntegerTypespec);
#endif
#ifdef vpiTimeTypespec
    SHOW(vpiTimeTypespec);
#endif
#ifdef vpiRealTypespec
    SHOW(vpiRealTypespec);
#endif
#ifdef vpiStructTypespec
    SHOW(vpiStructTypespec);
#endif
#ifdef vpiUnionTypespec
    SHOW(vpiUnionTypespec);
#endif
#ifdef vpiBitTypespec
    SHOW(vpiBitTypespec);
#endif
#ifdef vpiLogicTypespec
    SHOW(vpiLogicTypespec);
#endif
#ifdef vpiArrayTypespec
    SHOW(vpiArrayTypespec);
#endif
#ifdef vpiVoidTypespec
    SHOW(vpiVoidTypespec);
#endif
#ifdef vpiTypespecMember
    SHOW(vpiTypespecMember);
#endif
#ifdef vpiPackedArrayTypespec
    SHOW(vpiPackedArrayTypespec);
#endif
#ifdef vpiSequenceTypespec
    SHOW(vpiSequenceTypespec);
#endif
#ifdef vpiPropertyTypespec
    SHOW(vpiPropertyTypespec);
#endif
#ifdef vpiEventTypespec
    SHOW(vpiEventTypespec);
#endif
#ifdef vpiInterfaceTypespec
    SHOW(vpiInterfaceTypespec);
#endif
#ifdef vpiClockingBlock
    SHOW(vpiClockingBlock);
#endif
#ifdef vpiClockingIODecl
    SHOW(vpiClockingIODecl);
#endif
#ifdef vpiClassDefn
    SHOW(vpiClassDefn);
#endif
#ifdef vpiConstraint
    SHOW(vpiConstraint);
#endif
#ifdef vpiConstraintOrdering
    SHOW(vpiConstraintOrdering);
#endif
#ifdef vpiDistItem
    SHOW(vpiDistItem);
#endif
#ifdef vpiAliasStmt
    SHOW(vpiAliasStmt);
#endif
#ifdef vpiThread
    SHOW(vpiThread);
#endif
#ifdef vpiMethodFuncCall
    SHOW(vpiMethodFuncCall);
#endif
#ifdef vpiMethodTaskCall
    SHOW(vpiMethodTaskCall);
#endif
#ifdef vpiAssert
    SHOW(vpiAssert);
#endif
#ifdef vpiAssume
    SHOW(vpiAssume);
#endif
#ifdef vpiCover
    SHOW(vpiCover);
#endif
#ifdef vpiRestrict
    SHOW(vpiRestrict);
#endif
#ifdef vpiDisableCondition
    SHOW(vpiDisableCondition);
#endif
#ifdef vpiClockingEvent
    SHOW(vpiClockingEvent);
#endif
#ifdef vpiPropertyDecl
    SHOW(vpiPropertyDecl);
#endif
#ifdef vpiPropertySpec
    SHOW(vpiPropertySpec);
#endif
#ifdef vpiPropertyExpr
    SHOW(vpiPropertyExpr);
#endif
#ifdef vpiMulticlockSequenceExpr
    SHOW(vpiMulticlockSequenceExpr);
#endif
#ifdef vpiClockedSeq
    SHOW(vpiClockedSeq);
#endif
#ifdef vpiClockedProp
    SHOW(vpiClockedProp);
#endif
#ifdef vpiPropertyInst
    SHOW(vpiPropertyInst);
#endif
#ifdef vpiSequenceDecl
    SHOW(vpiSequenceDecl);
#endif
#ifdef vpiCaseProperty
    SHOW(vpiCaseProperty);
#endif
#ifdef vpiCasePropertyItem
    SHOW(vpiCasePropertyItem);
#endif
#ifdef vpiSequenceInst
    SHOW(vpiSequenceInst);
#endif
#ifdef vpiImmediateAssert
    SHOW(vpiImmediateAssert);
#endif
#ifdef vpiImmediateAssume
    SHOW(vpiImmediateAssume);
#endif
#ifdef vpiImmediateCover
    SHOW(vpiImmediateCover);
#endif
#ifdef vpiReturn
    SHOW(vpiReturn);
#endif
#ifdef vpiAnyPattern
    SHOW(vpiAnyPattern);
#endif
#ifdef vpiTaggedPattern
    SHOW(vpiTaggedPattern);
#endif
#ifdef vpiStructPattern
    SHOW(vpiStructPattern);
#endif
#ifdef vpiDoWhile
    SHOW(vpiDoWhile);
#endif
#ifdef vpiOrderedWait
    SHOW(vpiOrderedWait);
#endif
#ifdef vpiWaitFork
    SHOW(vpiWaitFork);
#endif
#ifdef vpiDisableFork
    SHOW(vpiDisableFork);
#endif
#ifdef vpiExpectStmt
    SHOW(vpiExpectStmt);
#endif
#ifdef vpiForeachStmt
    SHOW(vpiForeachStmt);
#endif
#ifdef vpiReturnStmt
    SHOW(vpiReturnStmt);
#endif
#ifdef vpiFinal
    SHOW(vpiFinal);
#endif
#ifdef vpiExtends
    SHOW(vpiExtends);
#endif
#ifdef vpiDistribution
    SHOW(vpiDistribution);
#endif
#ifdef vpiSeqFormalDecl
    SHOW(vpiSeqFormalDecl);
#endif
#ifdef vpiPropFormalDecl
    SHOW(vpiPropFormalDecl);
#endif
#ifdef vpiArrayNet
    SHOW(vpiArrayNet);
#endif
#ifdef vpiEnumNet
    SHOW(vpiEnumNet);
#endif
#ifdef vpiIntegerNet
    SHOW(vpiIntegerNet);
#endif
#ifdef vpiLogicNet
    SHOW(vpiLogicNet);
#endif
#ifdef vpiTimeNet
    SHOW(vpiTimeNet);
#endif
#ifdef vpiUnionNet
    SHOW(vpiUnionNet);
#endif
#ifdef vpiShortRealNet
    SHOW(vpiShortRealNet);
#endif
#ifdef vpiRealNet
    SHOW(vpiRealNet);
#endif
#ifdef vpiByteNet
    SHOW(vpiByteNet);
#endif
#ifdef vpiShortIntNet
    SHOW(vpiShortIntNet);
#endif
#ifdef vpiIntNet
    SHOW(vpiIntNet);
#endif
#ifdef vpiLongIntNet
    SHOW(vpiLongIntNet);
#endif
#ifdef vpiBitNet
    SHOW(vpiBitNet);
#endif
#ifdef vpiInterconnectNet
    SHOW(vpiInterconnectNet);
#endif
#ifdef vpiInterconnectArray
    SHOW(vpiInterconnectArray);
#endif
#ifdef vpiStructNet
    SHOW(vpiStructNet);
#endif
#ifdef vpiBreak
    SHOW(vpiBreak);
#endif
#ifdef vpiContinue
    SHOW(vpiContinue);
#endif
#ifdef vpiPackedArrayNet
    SHOW(vpiPackedArrayNet);
#endif
#ifdef vpiNettypeDecl
    SHOW(vpiNettypeDecl);
#endif
#ifdef vpiConstraintExpr
    SHOW(vpiConstraintExpr);
#endif
#ifdef vpiElseConst
    SHOW(vpiElseConst);
#endif
#ifdef vpiImplication
    SHOW(vpiImplication);
#endif
#ifdef vpiConstrIf
    SHOW(vpiConstrIf);
#endif
#ifdef vpiConstrIfElse
    SHOW(vpiConstrIfElse);
#endif
#ifdef vpiConstrForEach
    SHOW(vpiConstrForEach);
#endif
#ifdef vpiSoftDisable
    SHOW(vpiSoftDisable);
#endif
#ifdef vpiLetDecl
    SHOW(vpiLetDecl);
#endif
#ifdef vpiLetExpr
    SHOW(vpiLetExpr);
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
