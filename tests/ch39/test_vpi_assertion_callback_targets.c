/* VPI application of test_vpi_assertion_callback_targets (IEEE 1800-2023 39.4.2, 39.3.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_callback_targets"

static const PLI_INT32 all_reasons[] = {
    cbAssertionStart, cbAssertionSuccess, cbAssertionFailure, cbAssertionVacuousSuccess,
    cbAssertionDisabledEvaluation, cbAssertionStepSuccess, cbAssertionStepFailure,
    cbAssertionLock, cbAssertionUnlock, cbAssertionDisable, cbAssertionEnable,
    cbAssertionReset, cbAssertionKill, cbAssertionEnablePassAction,
    cbAssertionEnableFailAction, cbAssertionDisablePassAction, cbAssertionDisableFailAction,
    cbAssertionEnableNonvacuousAction, cbAssertionDisableVacuousAction,
};

static const PLI_INT32 instance_reasons[] = {
    cbAssertionStart, cbAssertionSuccess, cbAssertionFailure,
};

#define COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

static PLI_INT32 nothing(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                         p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    (void)reason;
    (void)cb_time;
    (void)assertion;
    (void)info;
    (void)user_data;
    return 0;
}

static int place(vpiHandle h, const PLI_INT32 *reasons, int n)
{
    int i, placed = 0;

    for (i = 0; h != NULL && i < n; i++)
        if (vpi_register_assertion_cb(h, reasons[i], nothing, NULL) != NULL)
            placed++;
    return placed;
}

static const char *type_name(vpiHandle h)
{
    if (h == NULL)
        return "no object";
    switch (vpi_get(vpiType, h)) {
    case vpiPropertyInst:
        return "property inst";
    case vpiSequenceInst:
        return "sequence inst";
    case vpiPropertySpec:
        return "property spec";
    default:
        return "another type";
    }
}

/* The property of a concurrent assertion, through its property specification if it has one. */
static vpiHandle property_of(vpiHandle assertion)
{
    vpiHandle p = assertion != NULL ? vpi_handle(vpiProperty, assertion) : NULL;

    if (p != NULL && vpi_get(vpiType, p) == vpiPropertySpec)
        p = vpi_handle(vpiPropertyExpr, p);
    return p;
}

static vpiHandle immediate_assert(void)
{
    vpiHandle it = vpi_iterate(vpiAssertion, NULL), h, found = NULL;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (found == NULL && vpi_get(vpiType, h) == vpiImmediateAssert)
            found = h;
    return found;
}

static PLI_INT32 place_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle ca = vpi_handle_by_name((PLI_BYTE8 *)TOP ".ca", NULL);
    vpiHandle ia = immediate_assert();
    vpiHandle prop = property_of(vpi_handle_by_name((PLI_BYTE8 *)TOP ".a_p", NULL));
    vpiHandle seq = property_of(vpi_handle_by_name((PLI_BYTE8 *)TOP ".c_s", NULL));

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"concurrent assertion ca: %d of %d reasons placed\n",
               place(ca, all_reasons, COUNT(all_reasons)), COUNT(all_reasons));
    vpi_printf((PLI_BYTE8 *)"immediate assertion ia: %d of %d reasons placed\n",
               place(ia, all_reasons, COUNT(all_reasons)), COUNT(all_reasons));
    vpi_printf((PLI_BYTE8 *)"property of a_p: %s, %d of %d reasons placed\n", type_name(prop),
               place(prop, instance_reasons, COUNT(instance_reasons)), COUNT(instance_reasons));
    vpi_printf((PLI_BYTE8 *)"property expression of c_s: %s, %d of %d reasons placed\n",
               type_name(seq), place(seq, instance_reasons, COUNT(instance_reasons)),
               COUNT(instance_reasons));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_place";
    d.calltf = place_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
