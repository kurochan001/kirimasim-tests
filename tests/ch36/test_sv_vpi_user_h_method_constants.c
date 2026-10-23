/* VPI application of test_sv_vpi_user_h_method_constants (IEEE 1800-2023 36.7, M.2). */
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
#ifdef vpiActual
    SHOW(vpiActual);
#endif
#ifdef vpiTypedefAlias
    SHOW(vpiTypedefAlias);
#endif
#ifdef vpiIndexTypespec
    SHOW(vpiIndexTypespec);
#endif
#ifdef vpiBaseTypespec
    SHOW(vpiBaseTypespec);
#endif
#ifdef vpiElemTypespec
    SHOW(vpiElemTypespec);
#endif
#ifdef vpiNetTypedefAlias
    SHOW(vpiNetTypedefAlias);
#endif
#ifdef vpiInputSkew
    SHOW(vpiInputSkew);
#endif
#ifdef vpiOutputSkew
    SHOW(vpiOutputSkew);
#endif
#ifdef vpiGlobalClocking
    SHOW(vpiGlobalClocking);
#endif
#ifdef vpiDefaultClocking
    SHOW(vpiDefaultClocking);
#endif
#ifdef vpiDefaultDisableIff
    SHOW(vpiDefaultDisableIff);
#endif
#ifdef vpiOrigin
    SHOW(vpiOrigin);
#endif
#ifdef vpiPrefix
    SHOW(vpiPrefix);
#endif
#ifdef vpiWith
    SHOW(vpiWith);
#endif
#ifdef vpiProperty
    SHOW(vpiProperty);
#endif
#ifdef vpiValueRange
    SHOW(vpiValueRange);
#endif
#ifdef vpiPattern
    SHOW(vpiPattern);
#endif
#ifdef vpiWeight
    SHOW(vpiWeight);
#endif
#ifdef vpiConstraintItem
    SHOW(vpiConstraintItem);
#endif
#ifdef vpiTypedef
    SHOW(vpiTypedef);
#endif
#ifdef vpiImport
    SHOW(vpiImport);
#endif
#ifdef vpiDerivedClasses
    SHOW(vpiDerivedClasses);
#endif
#ifdef vpiInterfaceDecl
    SHOW(vpiInterfaceDecl);
#endif
#ifdef vpiMethods
    SHOW(vpiMethods);
#endif
#ifdef vpiSolveBefore
    SHOW(vpiSolveBefore);
#endif
#ifdef vpiSolveAfter
    SHOW(vpiSolveAfter);
#endif
#ifdef vpiWaitingProcesses
    SHOW(vpiWaitingProcesses);
#endif
#ifdef vpiMessages
    SHOW(vpiMessages);
#endif
#ifdef vpiLoopVars
    SHOW(vpiLoopVars);
#endif
#ifdef vpiConcurrentAssertion
    SHOW(vpiConcurrentAssertion);
#endif
#ifdef vpiConcurrentAssertions
    SHOW(vpiConcurrentAssertions);
#endif
#ifdef vpiMatchItem
    SHOW(vpiMatchItem);
#endif
#ifdef vpiMember
    SHOW(vpiMember);
#endif
#ifdef vpiElement
    SHOW(vpiElement);
#endif
#ifdef vpiAssertion
    SHOW(vpiAssertion);
#endif
#ifdef vpiInstance
    SHOW(vpiInstance);
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
