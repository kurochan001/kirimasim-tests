/* VPI application of test_vpi_property_sequence_exprs (IEEE 1800-2023 37.52, 37.54). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_property_sequence_exprs"

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int count(PLI_INT32 type, vpiHandle ref)
{
    vpiHandle it = vpi_iterate(type, ref);
    int n = 0;
    while (it != NULL && vpi_scan(it) != NULL)
        n++;
    return n;
}

static vpiHandle decl(PLI_INT32 type, const char *name)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top ? vpi_iterate(type, top) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), name) == 0)
            found = h;
    if (found == NULL)
        vpi_printf((PLI_BYTE8 *)"%s not found\n", name);
    return found;
}

static void operands(vpiHandle op)
{
    vpiHandle it = vpi_iterate(vpiOperand, op), h;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, h) == vpiConstant)
            vpi_printf((PLI_BYTE8 *)" %d", int_value(h));
        else
            vpi_printf((PLI_BYTE8 *)" %s", name_of(h));
    }
}

static const char *event_signal(vpiHandle ev)
{
    vpiHandle it, h;
    if (ev == NULL)
        return "none";
    if (vpi_get(vpiType, ev) != vpiOperation)
        return name_of(ev);
    it = vpi_iterate(vpiOperand, ev);
    h = it ? vpi_scan(it) : NULL;
    if (h != NULL)
        vpi_free_object(it);
    return name_of(h);
}

static PLI_INT32 exprs_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle d, e, it, h, spec, pe, second;

    (void)user_data;
    if ((d = decl(vpiSequenceDecl, "s_delay")) != NULL && (e = vpi_handle(vpiExpr, d)) != NULL) {
        vpi_printf((PLI_BYTE8 *)"s_delay: cycle delay %d, %d operands:",
                   vpi_get(vpiOpType, e) == vpiCycleDelayOp, count(vpiOperand, e));
        operands(e);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    if ((d = decl(vpiSequenceDecl, "s_rep")) != NULL && (e = vpi_handle(vpiExpr, d)) != NULL) {
        vpi_printf((PLI_BYTE8 *)"s_rep: consecutive repeat %d, %d operands:",
                   vpi_get(vpiOpType, e) == vpiConsecutiveRepeatOp, count(vpiOperand, e));
        operands(e);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    if ((d = decl(vpiSequenceDecl, "s_multi")) != NULL && (e = vpi_handle(vpiExpr, d)) != NULL) {
        vpi_printf((PLI_BYTE8 *)"s_multi: multiclock %d, clocked sequences on",
                   vpi_get(vpiType, e) == vpiMulticlockSequenceExpr);
        it = vpi_iterate(vpiClockedSeq, e);
        while (it != NULL && (h = vpi_scan(it)) != NULL)
            vpi_printf((PLI_BYTE8 *)" %s", event_signal(vpi_handle(vpiClockingEvent, h)));
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    d = decl(vpiPropertyDecl, "p_imp");
    if (d != NULL && (spec = vpi_handle(vpiPropertySpec, d)) != NULL) {
        pe = vpi_handle(vpiPropertyExpr, spec);
        it = pe ? vpi_iterate(vpiOperand, pe) : NULL;
        second = NULL;
        if (it != NULL && vpi_scan(it) != NULL)
            second = vpi_scan(it);
        vpi_printf((PLI_BYTE8 *)"p_imp: clocked by %s, overlapping implication %d, "
                   "then nexttime %d with %d operand\n",
                   event_signal(vpi_handle(vpiClockingEvent, spec)),
                   pe && vpi_get(vpiOpType, pe) == vpiOverlapImplyOp,
                   second && vpi_get(vpiOpType, second) == vpiNexttimeOp,
                   second ? count(vpiOperand, second) : -1);
    }
    d = decl(vpiPropertyDecl, "p_ev");
    if (d != NULL && (spec = vpi_handle(vpiPropertySpec, d)) != NULL) {
        pe = vpi_handle(vpiPropertyExpr, spec);
        vpi_printf((PLI_BYTE8 *)"p_ev: eventually %d, strong %d, %d operands\n",
                   pe && vpi_get(vpiOpType, pe) == vpiEventuallyOp,
                   pe ? (int)vpi_get(vpiOpStrong, pe) : -1,
                   pe ? count(vpiOperand, pe) : -1);
    }
    d = decl(vpiPropertyDecl, "p_inst");
    if (d != NULL && (spec = vpi_handle(vpiPropertySpec, d)) != NULL) {
        pe = vpi_handle(vpiPropertyExpr, spec);
        vpi_printf((PLI_BYTE8 *)"p_inst: instance of %s, arguments:",
                   pe && vpi_get(vpiType, pe) == vpiSequenceInst
                       ? name_of(vpi_handle(vpiSequenceDecl, pe)) : "none");
        it = pe ? vpi_iterate(vpiArgument, pe) : NULL;
        while (it != NULL && (h = vpi_scan(it)) != NULL) {
            if (vpi_get(vpiType, h) == vpiConstant)
                vpi_printf((PLI_BYTE8 *)" %d", int_value(h));
            else
                vpi_printf((PLI_BYTE8 *)" %s", name_of(h));
        }
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_exprs", exprs_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
