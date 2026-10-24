/* VPI application of test_vpi_property_operator_kinds (IEEE 1800-2023 37.52). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_property_operator_kinds"

static vpiHandle top;

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *op_name(PLI_INT32 op)
{
    switch (op) {
    case vpiNotOp: return "not";
    case vpiCompOrOp: return "or";
    case vpiIfElseOp: return "if-else";
    case vpiIfOp: return "if";
    case vpiIffOp: return "iff";
    case vpiImpliesOp: return "implies";
    case vpiNonOverlapImplyOp: return "|=>";
    case vpiOverlapImplyOp: return "|->";
    case vpiOverlapFollowedByOp: return "#-#";
    case vpiNonOverlapFollowedByOp: return "#=#";
    case vpiAcceptOnOp: return "accept_on";
    case vpiRejectOnOp: return "reject_on";
    case vpiSyncAcceptOnOp: return "sync_accept_on";
    case vpiSyncRejectOnOp: return "sync_reject_on";
    case vpiUntilOp: return "until";
    case vpiUntilWithOp: return "until_with";
    case vpiNexttimeOp: return "nexttime";
    case vpiAlwaysOp: return "always";
    case vpiEventuallyOp: return "eventually";
    case vpiCycleDelayOp: return "##";
    case vpiPosedgeOp: return "posedge";
    case vpiNegedgeOp: return "negedge";
    default: return "other operation";
    }
}

static int has_strength(PLI_INT32 op)
{
    return op == vpiNexttimeOp || op == vpiAlwaysOp || op == vpiEventuallyOp ||
           op == vpiUntilOp || op == vpiUntilWithOp || op == vpiCycleDelayOp;
}

/* A constant as its value, an operation as "(op)", a property instance as
 * "instance of" its declaration, anything else by name. */
static void operand_text(vpiHandle h, char *out, size_t len)
{
    if (h == NULL)
        snprintf(out, len, "(none)");
    else if (vpi_get(vpiType, h) == vpiConstant)
        snprintf(out, len, "%d", int_value(h));
    else if (vpi_get(vpiType, h) == vpiOperation)
        snprintf(out, len, "(%s)", op_name(vpi_get(vpiOpType, h)));
    else if (vpi_get(vpiType, h) == vpiPropertyInst)
        snprintf(out, len, "instance of %s", name_of(vpi_handle(vpiPropertyDecl, h)));
    else
        snprintf(out, len, "%s", name_of(h));
}

static vpiHandle spec_of(const char *name)
{
    vpiHandle it = top != NULL ? vpi_iterate(vpiPropertyDecl, top) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), name) == 0)
            found = h;
    return found != NULL ? vpi_handle(vpiPropertySpec, found) : NULL;
}

static void show(const char *name)
{
    vpiHandle spec = spec_of(name), e, it, h;
    char text[64];
    PLI_INT32 op;

    e = spec != NULL ? vpi_handle(vpiPropertyExpr, spec) : NULL;
    if (e == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no property expression\n", name);
        return;
    }
    if (vpi_get(vpiType, e) != vpiOperation) {
        operand_text(e, text, sizeof text);
        vpi_printf((PLI_BYTE8 *)"%s: %s %s\n", name,
                   vpi_get(vpiType, e) == vpiPropertyInst ? "property instance" : "expression",
                   text);
        return;
    }
    op = vpi_get(vpiOpType, e);
    vpi_printf((PLI_BYTE8 *)"%s: %s", name, op_name(op));
    if (has_strength(op))
        vpi_printf((PLI_BYTE8 *)", strong %d", (int)vpi_get(vpiOpStrong, e));
    vpi_printf((PLI_BYTE8 *)", operands:");
    it = vpi_iterate(vpiOperand, e);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        operand_text(h, text, sizeof text);
        vpi_printf((PLI_BYTE8 *)" %s", text);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void show_clock(const char *name)
{
    vpiHandle spec = spec_of(name), ev, it, h = NULL;
    char text[64];

    ev = spec != NULL ? vpi_handle(vpiClockingEvent, spec) : NULL;
    if (ev == NULL || vpi_get(vpiType, ev) != vpiOperation) {
        vpi_printf((PLI_BYTE8 *)"%s: clocking event %s\n", name, ev == NULL ? "NULL"
                   : "not an operation");
        return;
    }
    it = vpi_iterate(vpiOperand, ev);
    if (it != NULL && (h = vpi_scan(it)) != NULL)
        vpi_free_object(it);
    operand_text(vpi_handle(vpiPropertyExpr, spec), text, sizeof text);
    vpi_printf((PLI_BYTE8 *)"%s: clocking event %s %s, property expression %s\n", name,
               op_name(vpi_get(vpiOpType, ev)), name_of(h), text);
}

static PLI_INT32 props_calltf(PLI_BYTE8 *user_data)
{
    static const char *const names[] = {
        "p_inner", "p_inst", "p_not", "p_or", "p_ifelse", "p_if", "p_iff", "p_implies",
        "p_nimp", "p_ofb", "p_nofb", "p_acc", "p_rej", "p_sacc", "p_srej", "p_until",
        "p_suntil", "p_uw", "p_suw", "p_next", "p_snext3", "p_alw", "p_salw", "p_ev",
        "p_sev", "p_seqw", "p_seqs", NULL};
    int i;

    (void)user_data;
    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    for (i = 0; names[i] != NULL; i++)
        show(names[i]);
    show_clock("p_clk");
    show_clock("p_clk2");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_props";
    d.calltf = props_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
