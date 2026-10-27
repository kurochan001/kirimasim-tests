/* VPI application of test_vpi_user_h_structure_constants (IEEE 1800-2023 36.7, K.2). */
#include <limits.h>
#include <string.h>
#include "vpi_user.h"
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
#ifdef vpiScaledRealTime
    SHOW(vpiScaledRealTime);
#endif
#ifdef vpiSimTime
    SHOW(vpiSimTime);
#endif
#ifdef vpiSuppressTime
    SHOW(vpiSuppressTime);
#endif
#ifdef vpiSupplyDrive
    SHOW(vpiSupplyDrive);
#endif
#ifdef vpiStrongDrive
    SHOW(vpiStrongDrive);
#endif
#ifdef vpiPullDrive
    SHOW(vpiPullDrive);
#endif
#ifdef vpiWeakDrive
    SHOW(vpiWeakDrive);
#endif
#ifdef vpiHiZ
    SHOW(vpiHiZ);
#endif
#ifdef vpiBinStrVal
    SHOW(vpiBinStrVal);
#endif
#ifdef vpiOctStrVal
    SHOW(vpiOctStrVal);
#endif
#ifdef vpiDecStrVal
    SHOW(vpiDecStrVal);
#endif
#ifdef vpiHexStrVal
    SHOW(vpiHexStrVal);
#endif
#ifdef vpiScalarVal
    SHOW(vpiScalarVal);
#endif
#ifdef vpiIntVal
    SHOW(vpiIntVal);
#endif
#ifdef vpiRealVal
    SHOW(vpiRealVal);
#endif
#ifdef vpiStringVal
    SHOW(vpiStringVal);
#endif
#ifdef vpiVectorVal
    SHOW(vpiVectorVal);
#endif
#ifdef vpiStrengthVal
    SHOW(vpiStrengthVal);
#endif
#ifdef vpiTimeVal
    SHOW(vpiTimeVal);
#endif
#ifdef vpiObjTypeVal
    SHOW(vpiObjTypeVal);
#endif
#ifdef vpiSuppressVal
    SHOW(vpiSuppressVal);
#endif
#ifdef vpiShortIntVal
    SHOW(vpiShortIntVal);
#endif
#ifdef vpiLongIntVal
    SHOW(vpiLongIntVal);
#endif
#ifdef vpiShortRealVal
    SHOW(vpiShortRealVal);
#endif
#ifdef vpiRawTwoStateVal
    SHOW(vpiRawTwoStateVal);
#endif
#ifdef vpiRawFourStateVal
    SHOW(vpiRawFourStateVal);
#endif
#ifdef vpiNoDelay
    SHOW(vpiNoDelay);
#endif
#ifdef vpiInertialDelay
    SHOW(vpiInertialDelay);
#endif
#ifdef vpiTransportDelay
    SHOW(vpiTransportDelay);
#endif
#ifdef vpiPureTransportDelay
    SHOW(vpiPureTransportDelay);
#endif
#ifdef vpiForceFlag
    SHOW(vpiForceFlag);
#endif
#ifdef vpiReleaseFlag
    SHOW(vpiReleaseFlag);
#endif
#ifdef vpiCancelEvent
    SHOW(vpiCancelEvent);
#endif
#ifdef vpiReturnEvent
    SHOW(vpiReturnEvent);
#endif
#ifdef vpiUserAllocFlag
    SHOW(vpiUserAllocFlag);
#endif
#ifdef vpiOneValue
    SHOW(vpiOneValue);
#endif
#ifdef vpiPropagateOff
    SHOW(vpiPropagateOff);
#endif
#ifdef vpi0
    SHOW(vpi0);
#endif
#ifdef vpi1
    SHOW(vpi1);
#endif
#ifdef vpiZ
    SHOW(vpiZ);
#endif
#ifdef vpiX
    SHOW(vpiX);
#endif
#ifdef vpiH
    SHOW(vpiH);
#endif
#ifdef vpiL
    SHOW(vpiL);
#endif
#ifdef vpiDontCare
    SHOW(vpiDontCare);
#endif
#ifdef vpiSysTask
    SHOW(vpiSysTask);
#endif
#ifdef vpiSysFunc
    SHOW(vpiSysFunc);
#endif
#ifdef vpiCompile
    SHOW(vpiCompile);
#endif
#ifdef vpiPLI
    SHOW(vpiPLI);
#endif
#ifdef vpiRun
    SHOW(vpiRun);
#endif
#ifdef vpiNotice
    SHOW(vpiNotice);
#endif
#ifdef vpiWarning
    SHOW(vpiWarning);
#endif
#ifdef vpiError
    SHOW(vpiError);
#endif
#ifdef vpiSystem
    SHOW(vpiSystem);
#endif
#ifdef vpiInternal
    SHOW(vpiInternal);
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
