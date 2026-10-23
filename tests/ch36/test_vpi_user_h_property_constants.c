/* VPI application of test_vpi_user_h_property_constants (IEEE 1800-2023 36.7, K.2). */
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
#ifdef vpiUndefined
    SHOW(vpiUndefined);
#endif
#ifdef vpiType
    SHOW(vpiType);
#endif
#ifdef vpiName
    SHOW(vpiName);
#endif
#ifdef vpiFullName
    SHOW(vpiFullName);
#endif
#ifdef vpiSize
    SHOW(vpiSize);
#endif
#ifdef vpiFile
    SHOW(vpiFile);
#endif
#ifdef vpiLineNo
    SHOW(vpiLineNo);
#endif
#ifdef vpiTopModule
    SHOW(vpiTopModule);
#endif
#ifdef vpiCellInstance
    SHOW(vpiCellInstance);
#endif
#ifdef vpiDefName
    SHOW(vpiDefName);
#endif
#ifdef vpiProtected
    SHOW(vpiProtected);
#endif
#ifdef vpiTimeUnit
    SHOW(vpiTimeUnit);
#endif
#ifdef vpiTimePrecision
    SHOW(vpiTimePrecision);
#endif
#ifdef vpiDefNetType
    SHOW(vpiDefNetType);
#endif
#ifdef vpiUnconnDrive
    SHOW(vpiUnconnDrive);
#endif
#ifdef vpiHighZ
    SHOW(vpiHighZ);
#endif
#ifdef vpiPull1
    SHOW(vpiPull1);
#endif
#ifdef vpiPull0
    SHOW(vpiPull0);
#endif
#ifdef vpiDefFile
    SHOW(vpiDefFile);
#endif
#ifdef vpiDefLineNo
    SHOW(vpiDefLineNo);
#endif
#ifdef vpiDefDelayMode
    SHOW(vpiDefDelayMode);
#endif
#ifdef vpiDelayModeNone
    SHOW(vpiDelayModeNone);
#endif
#ifdef vpiDelayModePath
    SHOW(vpiDelayModePath);
#endif
#ifdef vpiDelayModeDistrib
    SHOW(vpiDelayModeDistrib);
#endif
#ifdef vpiDelayModeUnit
    SHOW(vpiDelayModeUnit);
#endif
#ifdef vpiDelayModeZero
    SHOW(vpiDelayModeZero);
#endif
#ifdef vpiDelayModeMTM
    SHOW(vpiDelayModeMTM);
#endif
#ifdef vpiDefDecayTime
    SHOW(vpiDefDecayTime);
#endif
#ifdef vpiScalar
    SHOW(vpiScalar);
#endif
#ifdef vpiVector
    SHOW(vpiVector);
#endif
#ifdef vpiExplicitName
    SHOW(vpiExplicitName);
#endif
#ifdef vpiDirection
    SHOW(vpiDirection);
#endif
#ifdef vpiInput
    SHOW(vpiInput);
#endif
#ifdef vpiOutput
    SHOW(vpiOutput);
#endif
#ifdef vpiInout
    SHOW(vpiInout);
#endif
#ifdef vpiMixedIO
    SHOW(vpiMixedIO);
#endif
#ifdef vpiNoDirection
    SHOW(vpiNoDirection);
#endif
#ifdef vpiConnByName
    SHOW(vpiConnByName);
#endif
#ifdef vpiNetType
    SHOW(vpiNetType);
#endif
#ifdef vpiWire
    SHOW(vpiWire);
#endif
#ifdef vpiWand
    SHOW(vpiWand);
#endif
#ifdef vpiWor
    SHOW(vpiWor);
#endif
#ifdef vpiTri
    SHOW(vpiTri);
#endif
#ifdef vpiTri0
    SHOW(vpiTri0);
#endif
#ifdef vpiTri1
    SHOW(vpiTri1);
#endif
#ifdef vpiTriReg
    SHOW(vpiTriReg);
#endif
#ifdef vpiTriAnd
    SHOW(vpiTriAnd);
#endif
#ifdef vpiTriOr
    SHOW(vpiTriOr);
#endif
#ifdef vpiSupply1
    SHOW(vpiSupply1);
#endif
#ifdef vpiSupply0
    SHOW(vpiSupply0);
#endif
#ifdef vpiNone
    SHOW(vpiNone);
#endif
#ifdef vpiUwire
    SHOW(vpiUwire);
#endif
#ifdef vpiNettypeNet
    SHOW(vpiNettypeNet);
#endif
#ifdef vpiNettypeNetSelect
    SHOW(vpiNettypeNetSelect);
#endif
#ifdef vpiInterconnect
    SHOW(vpiInterconnect);
#endif
#ifdef vpiExplicitScalared
    SHOW(vpiExplicitScalared);
#endif
#ifdef vpiExplicitVectored
    SHOW(vpiExplicitVectored);
#endif
#ifdef vpiExpanded
    SHOW(vpiExpanded);
#endif
#ifdef vpiImplicitDecl
    SHOW(vpiImplicitDecl);
#endif
#ifdef vpiChargeStrength
    SHOW(vpiChargeStrength);
#endif
#ifdef vpiLargeCharge
    SHOW(vpiLargeCharge);
#endif
#ifdef vpiMediumCharge
    SHOW(vpiMediumCharge);
#endif
#ifdef vpiSmallCharge
    SHOW(vpiSmallCharge);
#endif
#ifdef vpiArray
    SHOW(vpiArray);
#endif
#ifdef vpiPortIndex
    SHOW(vpiPortIndex);
#endif
#ifdef vpiTermIndex
    SHOW(vpiTermIndex);
#endif
#ifdef vpiStrength0
    SHOW(vpiStrength0);
#endif
#ifdef vpiStrength1
    SHOW(vpiStrength1);
#endif
#ifdef vpiPrimType
    SHOW(vpiPrimType);
#endif
#ifdef vpiAndPrim
    SHOW(vpiAndPrim);
#endif
#ifdef vpiNandPrim
    SHOW(vpiNandPrim);
#endif
#ifdef vpiNorPrim
    SHOW(vpiNorPrim);
#endif
#ifdef vpiOrPrim
    SHOW(vpiOrPrim);
#endif
#ifdef vpiXorPrim
    SHOW(vpiXorPrim);
#endif
#ifdef vpiXnorPrim
    SHOW(vpiXnorPrim);
#endif
#ifdef vpiBufPrim
    SHOW(vpiBufPrim);
#endif
#ifdef vpiNotPrim
    SHOW(vpiNotPrim);
#endif
#ifdef vpiBufif0Prim
    SHOW(vpiBufif0Prim);
#endif
#ifdef vpiBufif1Prim
    SHOW(vpiBufif1Prim);
#endif
#ifdef vpiNotif0Prim
    SHOW(vpiNotif0Prim);
#endif
#ifdef vpiNotif1Prim
    SHOW(vpiNotif1Prim);
#endif
#ifdef vpiNmosPrim
    SHOW(vpiNmosPrim);
#endif
#ifdef vpiPmosPrim
    SHOW(vpiPmosPrim);
#endif
#ifdef vpiCmosPrim
    SHOW(vpiCmosPrim);
#endif
#ifdef vpiRnmosPrim
    SHOW(vpiRnmosPrim);
#endif
#ifdef vpiRpmosPrim
    SHOW(vpiRpmosPrim);
#endif
#ifdef vpiRcmosPrim
    SHOW(vpiRcmosPrim);
#endif
#ifdef vpiRtranPrim
    SHOW(vpiRtranPrim);
#endif
#ifdef vpiRtranif0Prim
    SHOW(vpiRtranif0Prim);
#endif
#ifdef vpiRtranif1Prim
    SHOW(vpiRtranif1Prim);
#endif
#ifdef vpiTranPrim
    SHOW(vpiTranPrim);
#endif
#ifdef vpiTranif0Prim
    SHOW(vpiTranif0Prim);
#endif
#ifdef vpiTranif1Prim
    SHOW(vpiTranif1Prim);
#endif
#ifdef vpiPullupPrim
    SHOW(vpiPullupPrim);
#endif
#ifdef vpiPulldownPrim
    SHOW(vpiPulldownPrim);
#endif
#ifdef vpiSeqPrim
    SHOW(vpiSeqPrim);
#endif
#ifdef vpiCombPrim
    SHOW(vpiCombPrim);
#endif
#ifdef vpiPolarity
    SHOW(vpiPolarity);
#endif
#ifdef vpiDataPolarity
    SHOW(vpiDataPolarity);
#endif
#ifdef vpiPositive
    SHOW(vpiPositive);
#endif
#ifdef vpiNegative
    SHOW(vpiNegative);
#endif
#ifdef vpiUnknown
    SHOW(vpiUnknown);
#endif
#ifdef vpiEdge
    SHOW(vpiEdge);
#endif
#ifdef vpiNoEdge
    SHOW(vpiNoEdge);
#endif
#ifdef vpiEdge01
    SHOW(vpiEdge01);
#endif
#ifdef vpiEdge10
    SHOW(vpiEdge10);
#endif
#ifdef vpiEdge0x
    SHOW(vpiEdge0x);
#endif
#ifdef vpiEdgex1
    SHOW(vpiEdgex1);
#endif
#ifdef vpiEdge1x
    SHOW(vpiEdge1x);
#endif
#ifdef vpiEdgex0
    SHOW(vpiEdgex0);
#endif
#ifdef vpiPosedge
    SHOW(vpiPosedge);
#endif
#ifdef vpiNegedge
    SHOW(vpiNegedge);
#endif
#ifdef vpiAnyEdge
    SHOW(vpiAnyEdge);
#endif
#ifdef vpiPathType
    SHOW(vpiPathType);
#endif
#ifdef vpiPathFull
    SHOW(vpiPathFull);
#endif
#ifdef vpiPathParallel
    SHOW(vpiPathParallel);
#endif
#ifdef vpiTchkType
    SHOW(vpiTchkType);
#endif
#ifdef vpiSetup
    SHOW(vpiSetup);
#endif
#ifdef vpiHold
    SHOW(vpiHold);
#endif
#ifdef vpiPeriod
    SHOW(vpiPeriod);
#endif
#ifdef vpiWidth
    SHOW(vpiWidth);
#endif
#ifdef vpiSkew
    SHOW(vpiSkew);
#endif
#ifdef vpiRecovery
    SHOW(vpiRecovery);
#endif
#ifdef vpiNoChange
    SHOW(vpiNoChange);
#endif
#ifdef vpiSetupHold
    SHOW(vpiSetupHold);
#endif
#ifdef vpiFullskew
    SHOW(vpiFullskew);
#endif
#ifdef vpiRecrem
    SHOW(vpiRecrem);
#endif
#ifdef vpiRemoval
    SHOW(vpiRemoval);
#endif
#ifdef vpiTimeskew
    SHOW(vpiTimeskew);
#endif
#ifdef vpiOpType
    SHOW(vpiOpType);
#endif
#ifdef vpiMinusOp
    SHOW(vpiMinusOp);
#endif
#ifdef vpiPlusOp
    SHOW(vpiPlusOp);
#endif
#ifdef vpiNotOp
    SHOW(vpiNotOp);
#endif
#ifdef vpiBitNegOp
    SHOW(vpiBitNegOp);
#endif
#ifdef vpiUnaryAndOp
    SHOW(vpiUnaryAndOp);
#endif
#ifdef vpiUnaryNandOp
    SHOW(vpiUnaryNandOp);
#endif
#ifdef vpiUnaryOrOp
    SHOW(vpiUnaryOrOp);
#endif
#ifdef vpiUnaryNorOp
    SHOW(vpiUnaryNorOp);
#endif
#ifdef vpiUnaryXorOp
    SHOW(vpiUnaryXorOp);
#endif
#ifdef vpiUnaryXNorOp
    SHOW(vpiUnaryXNorOp);
#endif
#ifdef vpiSubOp
    SHOW(vpiSubOp);
#endif
#ifdef vpiDivOp
    SHOW(vpiDivOp);
#endif
#ifdef vpiModOp
    SHOW(vpiModOp);
#endif
#ifdef vpiEqOp
    SHOW(vpiEqOp);
#endif
#ifdef vpiNeqOp
    SHOW(vpiNeqOp);
#endif
#ifdef vpiCaseEqOp
    SHOW(vpiCaseEqOp);
#endif
#ifdef vpiCaseNeqOp
    SHOW(vpiCaseNeqOp);
#endif
#ifdef vpiGtOp
    SHOW(vpiGtOp);
#endif
#ifdef vpiGeOp
    SHOW(vpiGeOp);
#endif
#ifdef vpiLtOp
    SHOW(vpiLtOp);
#endif
#ifdef vpiLeOp
    SHOW(vpiLeOp);
#endif
#ifdef vpiLShiftOp
    SHOW(vpiLShiftOp);
#endif
#ifdef vpiRShiftOp
    SHOW(vpiRShiftOp);
#endif
#ifdef vpiAddOp
    SHOW(vpiAddOp);
#endif
#ifdef vpiMultOp
    SHOW(vpiMultOp);
#endif
#ifdef vpiLogAndOp
    SHOW(vpiLogAndOp);
#endif
#ifdef vpiLogOrOp
    SHOW(vpiLogOrOp);
#endif
#ifdef vpiBitAndOp
    SHOW(vpiBitAndOp);
#endif
#ifdef vpiBitOrOp
    SHOW(vpiBitOrOp);
#endif
#ifdef vpiBitXorOp
    SHOW(vpiBitXorOp);
#endif
#ifdef vpiBitXNorOp
    SHOW(vpiBitXNorOp);
#endif
#ifdef vpiBitXnorOp
    SHOW(vpiBitXnorOp);
#endif
#ifdef vpiConditionOp
    SHOW(vpiConditionOp);
#endif
#ifdef vpiConcatOp
    SHOW(vpiConcatOp);
#endif
#ifdef vpiMultiConcatOp
    SHOW(vpiMultiConcatOp);
#endif
#ifdef vpiEventOrOp
    SHOW(vpiEventOrOp);
#endif
#ifdef vpiNullOp
    SHOW(vpiNullOp);
#endif
#ifdef vpiListOp
    SHOW(vpiListOp);
#endif
#ifdef vpiMinTypMaxOp
    SHOW(vpiMinTypMaxOp);
#endif
#ifdef vpiPosedgeOp
    SHOW(vpiPosedgeOp);
#endif
#ifdef vpiNegedgeOp
    SHOW(vpiNegedgeOp);
#endif
#ifdef vpiArithLShiftOp
    SHOW(vpiArithLShiftOp);
#endif
#ifdef vpiArithRShiftOp
    SHOW(vpiArithRShiftOp);
#endif
#ifdef vpiPowerOp
    SHOW(vpiPowerOp);
#endif
#ifdef vpiConstType
    SHOW(vpiConstType);
#endif
#ifdef vpiDecConst
    SHOW(vpiDecConst);
#endif
#ifdef vpiRealConst
    SHOW(vpiRealConst);
#endif
#ifdef vpiBinaryConst
    SHOW(vpiBinaryConst);
#endif
#ifdef vpiOctConst
    SHOW(vpiOctConst);
#endif
#ifdef vpiHexConst
    SHOW(vpiHexConst);
#endif
#ifdef vpiStringConst
    SHOW(vpiStringConst);
#endif
#ifdef vpiIntConst
    SHOW(vpiIntConst);
#endif
#ifdef vpiTimeConst
    SHOW(vpiTimeConst);
#endif
#ifdef vpiBlocking
    SHOW(vpiBlocking);
#endif
#ifdef vpiCaseType
    SHOW(vpiCaseType);
#endif
#ifdef vpiCaseExact
    SHOW(vpiCaseExact);
#endif
#ifdef vpiCaseX
    SHOW(vpiCaseX);
#endif
#ifdef vpiCaseZ
    SHOW(vpiCaseZ);
#endif
#ifdef vpiNetDeclAssign
    SHOW(vpiNetDeclAssign);
#endif
#ifdef vpiFuncType
    SHOW(vpiFuncType);
#endif
#ifdef vpiIntFunc
    SHOW(vpiIntFunc);
#endif
#ifdef vpiRealFunc
    SHOW(vpiRealFunc);
#endif
#ifdef vpiTimeFunc
    SHOW(vpiTimeFunc);
#endif
#ifdef vpiSizedFunc
    SHOW(vpiSizedFunc);
#endif
#ifdef vpiSizedSignedFunc
    SHOW(vpiSizedSignedFunc);
#endif
#ifdef vpiSysFuncType
    SHOW(vpiSysFuncType);
#endif
#ifdef vpiSysFuncInt
    SHOW(vpiSysFuncInt);
#endif
#ifdef vpiSysFuncReal
    SHOW(vpiSysFuncReal);
#endif
#ifdef vpiSysFuncTime
    SHOW(vpiSysFuncTime);
#endif
#ifdef vpiSysFuncSized
    SHOW(vpiSysFuncSized);
#endif
#ifdef vpiUserDefn
    SHOW(vpiUserDefn);
#endif
#ifdef vpiScheduled
    SHOW(vpiScheduled);
#endif
#ifdef vpiActive
    SHOW(vpiActive);
#endif
#ifdef vpiAutomatic
    SHOW(vpiAutomatic);
#endif
#ifdef vpiCell
    SHOW(vpiCell);
#endif
#ifdef vpiConfig
    SHOW(vpiConfig);
#endif
#ifdef vpiConstantSelect
    SHOW(vpiConstantSelect);
#endif
#ifdef vpiDecompile
    SHOW(vpiDecompile);
#endif
#ifdef vpiDefAttribute
    SHOW(vpiDefAttribute);
#endif
#ifdef vpiDelayType
    SHOW(vpiDelayType);
#endif
#ifdef vpiModPathDelay
    SHOW(vpiModPathDelay);
#endif
#ifdef vpiInterModPathDelay
    SHOW(vpiInterModPathDelay);
#endif
#ifdef vpiMIPDelay
    SHOW(vpiMIPDelay);
#endif
#ifdef vpiIteratorType
    SHOW(vpiIteratorType);
#endif
#ifdef vpiLibrary
    SHOW(vpiLibrary);
#endif
#ifdef vpiOffset
    SHOW(vpiOffset);
#endif
#ifdef vpiResolvedNetType
    SHOW(vpiResolvedNetType);
#endif
#ifdef vpiSaveRestartID
    SHOW(vpiSaveRestartID);
#endif
#ifdef vpiSaveRestartLocation
    SHOW(vpiSaveRestartLocation);
#endif
#ifdef vpiValid
    SHOW(vpiValid);
#endif
#ifdef vpiValidFalse
    SHOW(vpiValidFalse);
#endif
#ifdef vpiValidTrue
    SHOW(vpiValidTrue);
#endif
#ifdef vpiSigned
    SHOW(vpiSigned);
#endif
#ifdef vpiLocalParam
    SHOW(vpiLocalParam);
#endif
#ifdef vpiModPathHasIfNone
    SHOW(vpiModPathHasIfNone);
#endif
#ifdef vpiIndexedPartSelectType
    SHOW(vpiIndexedPartSelectType);
#endif
#ifdef vpiPosIndexed
    SHOW(vpiPosIndexed);
#endif
#ifdef vpiNegIndexed
    SHOW(vpiNegIndexed);
#endif
#ifdef vpiIsMemory
    SHOW(vpiIsMemory);
#endif
#ifdef vpiIsProtected
    SHOW(vpiIsProtected);
#endif
#ifdef vpiStop
    SHOW(vpiStop);
#endif
#ifdef vpiFinish
    SHOW(vpiFinish);
#endif
#ifdef vpiReset
    SHOW(vpiReset);
#endif
#ifdef vpiSetInteractiveScope
    SHOW(vpiSetInteractiveScope);
#endif
#ifdef VPI_MCD_STDOUT
    SHOW(VPI_MCD_STDOUT);
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
