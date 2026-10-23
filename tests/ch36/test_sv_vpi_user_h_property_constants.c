/* VPI application of test_sv_vpi_user_h_property_constants (IEEE 1800-2023 36.7, M.2). */
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
#ifdef vpiTop
    SHOW(vpiTop);
#endif
#ifdef vpiUnit
    SHOW(vpiUnit);
#endif
#ifdef vpiJoinType
    SHOW(vpiJoinType);
#endif
#ifdef vpiJoin
    SHOW(vpiJoin);
#endif
#ifdef vpiJoinNone
    SHOW(vpiJoinNone);
#endif
#ifdef vpiJoinAny
    SHOW(vpiJoinAny);
#endif
#ifdef vpiAccessType
    SHOW(vpiAccessType);
#endif
#ifdef vpiForkJoinAcc
    SHOW(vpiForkJoinAcc);
#endif
#ifdef vpiExternAcc
    SHOW(vpiExternAcc);
#endif
#ifdef vpiDPIExportAcc
    SHOW(vpiDPIExportAcc);
#endif
#ifdef vpiDPIImportAcc
    SHOW(vpiDPIImportAcc);
#endif
#ifdef vpiArrayType
    SHOW(vpiArrayType);
#endif
#ifdef vpiStaticArray
    SHOW(vpiStaticArray);
#endif
#ifdef vpiDynamicArray
    SHOW(vpiDynamicArray);
#endif
#ifdef vpiAssocArray
    SHOW(vpiAssocArray);
#endif
#ifdef vpiQueueArray
    SHOW(vpiQueueArray);
#endif
#ifdef vpiArrayMember
    SHOW(vpiArrayMember);
#endif
#ifdef vpiIsRandomized
    SHOW(vpiIsRandomized);
#endif
#ifdef vpiLocalVarDecls
    SHOW(vpiLocalVarDecls);
#endif
#ifdef vpiOpStrong
    SHOW(vpiOpStrong);
#endif
#ifdef vpiRandType
    SHOW(vpiRandType);
#endif
#ifdef vpiNotRand
    SHOW(vpiNotRand);
#endif
#ifdef vpiRand
    SHOW(vpiRand);
#endif
#ifdef vpiRandC
    SHOW(vpiRandC);
#endif
#ifdef vpiPortType
    SHOW(vpiPortType);
#endif
#ifdef vpiInterfacePort
    SHOW(vpiInterfacePort);
#endif
#ifdef vpiModportPort
    SHOW(vpiModportPort);
#endif
#ifdef vpiConstantVariable
    SHOW(vpiConstantVariable);
#endif
#ifdef vpiStructUnionMember
    SHOW(vpiStructUnionMember);
#endif
#ifdef vpiVisibility
    SHOW(vpiVisibility);
#endif
#ifdef vpiPublicVis
    SHOW(vpiPublicVis);
#endif
#ifdef vpiProtectedVis
    SHOW(vpiProtectedVis);
#endif
#ifdef vpiLocalVis
    SHOW(vpiLocalVis);
#endif
#ifdef vpiOneStepConst
    SHOW(vpiOneStepConst);
#endif
#ifdef vpiUnboundedConst
    SHOW(vpiUnboundedConst);
#endif
#ifdef vpiNullConst
    SHOW(vpiNullConst);
#endif
#ifdef vpiAlwaysType
    SHOW(vpiAlwaysType);
#endif
#ifdef vpiAlwaysComb
    SHOW(vpiAlwaysComb);
#endif
#ifdef vpiAlwaysFF
    SHOW(vpiAlwaysFF);
#endif
#ifdef vpiAlwaysLatch
    SHOW(vpiAlwaysLatch);
#endif
#ifdef vpiDistType
    SHOW(vpiDistType);
#endif
#ifdef vpiEqualDist
    SHOW(vpiEqualDist);
#endif
#ifdef vpiDivDist
    SHOW(vpiDivDist);
#endif
#ifdef vpiPacked
    SHOW(vpiPacked);
#endif
#ifdef vpiTagged
    SHOW(vpiTagged);
#endif
#ifdef vpiRef
    SHOW(vpiRef);
#endif
#ifdef vpiVirtual
    SHOW(vpiVirtual);
#endif
#ifdef vpiHasActual
    SHOW(vpiHasActual);
#endif
#ifdef vpiIsConstraintEnabled
    SHOW(vpiIsConstraintEnabled);
#endif
#ifdef vpiSoft
    SHOW(vpiSoft);
#endif
#ifdef vpiClassType
    SHOW(vpiClassType);
#endif
#ifdef vpiMailboxClass
    SHOW(vpiMailboxClass);
#endif
#ifdef vpiSemaphoreClass
    SHOW(vpiSemaphoreClass);
#endif
#ifdef vpiUserDefinedClass
    SHOW(vpiUserDefinedClass);
#endif
#ifdef vpiProcessClass
    SHOW(vpiProcessClass);
#endif
#ifdef vpiMethod
    SHOW(vpiMethod);
#endif
#ifdef vpiIsClockInferred
    SHOW(vpiIsClockInferred);
#endif
#ifdef vpiIsDeferred
    SHOW(vpiIsDeferred);
#endif
#ifdef vpiIsFinal
    SHOW(vpiIsFinal);
#endif
#ifdef vpiIsCoverSequence
    SHOW(vpiIsCoverSequence);
#endif
#ifdef vpiQualifier
    SHOW(vpiQualifier);
#endif
#ifdef vpiNoQualifier
    SHOW(vpiNoQualifier);
#endif
#ifdef vpiUniqueQualifier
    SHOW(vpiUniqueQualifier);
#endif
#ifdef vpiPriorityQualifier
    SHOW(vpiPriorityQualifier);
#endif
#ifdef vpiTaggedQualifier
    SHOW(vpiTaggedQualifier);
#endif
#ifdef vpiRandQualifier
    SHOW(vpiRandQualifier);
#endif
#ifdef vpiInsideQualifier
    SHOW(vpiInsideQualifier);
#endif
#ifdef vpiInputEdge
    SHOW(vpiInputEdge);
#endif
#ifdef vpiOutputEdge
    SHOW(vpiOutputEdge);
#endif
#ifdef vpiGeneric
    SHOW(vpiGeneric);
#endif
#ifdef vpiCompatibilityMode
    SHOW(vpiCompatibilityMode);
#endif
#ifdef vpiMode1364v1995
    SHOW(vpiMode1364v1995);
#endif
#ifdef vpiMode1364v2001
    SHOW(vpiMode1364v2001);
#endif
#ifdef vpiMode1364v2005
    SHOW(vpiMode1364v2005);
#endif
#ifdef vpiMode1800v2005
    SHOW(vpiMode1800v2005);
#endif
#ifdef vpiMode1800v2009
    SHOW(vpiMode1800v2009);
#endif
#ifdef vpiPackedArrayMember
    SHOW(vpiPackedArrayMember);
#endif
#ifdef vpiStartLine
    SHOW(vpiStartLine);
#endif
#ifdef vpiColumn
    SHOW(vpiColumn);
#endif
#ifdef vpiEndLine
    SHOW(vpiEndLine);
#endif
#ifdef vpiEndColumn
    SHOW(vpiEndColumn);
#endif
#ifdef vpiAllocScheme
    SHOW(vpiAllocScheme);
#endif
#ifdef vpiAutomaticScheme
    SHOW(vpiAutomaticScheme);
#endif
#ifdef vpiDynamicScheme
    SHOW(vpiDynamicScheme);
#endif
#ifdef vpiOtherScheme
    SHOW(vpiOtherScheme);
#endif
#ifdef vpiObjId
    SHOW(vpiObjId);
#endif
#ifdef vpiDPIPure
    SHOW(vpiDPIPure);
#endif
#ifdef vpiDPIContext
    SHOW(vpiDPIContext);
#endif
#ifdef vpiDPICStr
    SHOW(vpiDPICStr);
#endif
#ifdef vpiDPI
    SHOW(vpiDPI);
#endif
#ifdef vpiDPIC
    SHOW(vpiDPIC);
#endif
#ifdef vpiDPICIdentifier
    SHOW(vpiDPICIdentifier);
#endif
#ifdef vpiIsModPort
    SHOW(vpiIsModPort);
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
