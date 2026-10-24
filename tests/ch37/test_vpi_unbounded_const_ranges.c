/* VPI application of test_vpi_unbounded_const_ranges (IEEE 1800-2023 37.59, 37.54). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_unbounded_const_ranges"

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "(no name)";
}

static const char *op_name(vpiHandle op)
{
    if (op == NULL)
        return "NULL";
    if (vpi_get(vpiType, op) != vpiOperation)
        return "not an operation";
    switch (vpi_get(vpiOpType, op)) {
    case vpiUnaryCycleDelayOp: return "unary cycle delay";
    case vpiCycleDelayOp: return "cycle delay";
    case vpiConsecutiveRepeatOp: return "consecutive repeat";
    case vpiGotoRepeatOp: return "goto repeat";
    case vpiRepeatOp: return "nonconsecutive repeat";
    case vpiOverlapImplyOp: return "overlapping implication";
    default: return "other operation";
    }
}

/* Prints the operands of op: $ for an unbounded constant, the value of another constant. */
static void operands(vpiHandle op)
{
    vpiHandle it = op != NULL ? vpi_iterate(vpiOperand, op) : NULL, h;
    s_vpi_value v;

    vpi_printf((PLI_BYTE8 *)", operands:");
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, h) != vpiConstant) {
            vpi_printf((PLI_BYTE8 *)" %s", name_of(h));
        } else if (vpi_get(vpiConstType, h) == vpiUnboundedConst) {
            vpi_printf((PLI_BYTE8 *)" $");
        } else {
            v.format = vpiIntVal;
            vpi_get_value(h, &v);
            vpi_printf((PLI_BYTE8 *)" %d", (int)v.value.integer);
        }
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static vpiHandle decl(PLI_INT32 type, const char *name)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top != NULL ? vpi_iterate(type, top) : NULL, h, found = NULL;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), name) == 0)
            found = h;
    return found;
}

static void sequence(const char *name)
{
    vpiHandle d = decl(vpiSequenceDecl, name);
    vpiHandle e = d != NULL ? vpi_handle(vpiExpr, d) : NULL;

    if (d == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: %s", name, op_name(e));
    operands(e);
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle d, spec, pe, it, consequent = NULL;

    (void)data;
    sequence("s_unary");
    sequence("s_delay");
    sequence("s_bounded");
    sequence("s_consec");
    sequence("s_goto");
    sequence("s_nonconsec");
    d = decl(vpiPropertyDecl, "p_imp");
    spec = d != NULL ? vpi_handle(vpiPropertySpec, d) : NULL;
    pe = spec != NULL ? vpi_handle(vpiPropertyExpr, spec) : NULL;
    it = pe != NULL ? vpi_iterate(vpiOperand, pe) : NULL;
    if (it != NULL && vpi_scan(it) != NULL && (consequent = vpi_scan(it)) != NULL)
        vpi_free_object(it);
    vpi_printf((PLI_BYTE8 *)"p_imp: %s, consequent %s", op_name(pe), op_name(consequent));
    operands(consequent);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = start_of_simulation;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
