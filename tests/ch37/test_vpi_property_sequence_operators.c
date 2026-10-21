/* VPI application of test_vpi_property_sequence_operators (IEEE 1800-2023 37.52 to 37.57). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_property_sequence_operators"
#define MAX 8

static vpiHandle top;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_of(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "none";
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
    case vpiNexttimeOp: return "nexttime";
    case vpiAlwaysOp: return "always";
    case vpiUntilOp: return "until";
    case vpiCompAndOp: return "and";
    case vpiOverlapImplyOp: return "|->";
    case vpiUnaryCycleDelayOp: return "unary ##";
    case vpiCycleDelayOp: return "##";
    case vpiGotoRepeatOp: return "[->]";
    case vpiRepeatOp: return "[=]";
    case vpiThroughoutOp: return "throughout";
    case vpiWithinOp: return "within";
    case vpiFirstMatchOp: return "first_match";
    case vpiIntersectOp: return "intersect";
    case vpiAddOp: return "+";
    case vpiPosedgeOp: return "posedge";
    case vpiNegedgeOp: return "negedge";
    default: return "other operation";
    }
}

/* A constant as its value, an operation as "(op)", anything else by name. */
static void print_operand(vpiHandle h)
{
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)" (none)");
    else if (vpi_get(vpiType, h) == vpiConstant)
        vpi_printf((PLI_BYTE8 *)" %d", int_value(h));
    else if (vpi_get(vpiType, h) == vpiOperation)
        vpi_printf((PLI_BYTE8 *)" (%s)", op_name(vpi_get(vpiOpType, h)));
    else
        vpi_printf((PLI_BYTE8 *)" %s", name_of(h));
}

/* "posedge clk" for the operation of an event, or a name. */
static void event_text(vpiHandle ev, char *buf, size_t size)
{
    vpiHandle it, operand = NULL;

    if (ev == NULL || vpi_get(vpiType, ev) != vpiOperation) {
        snprintf(buf, size, "%s", name_of(ev));
        return;
    }
    it = vpi_iterate(vpiOperand, ev);
    if (it != NULL && (operand = vpi_scan(it)) != NULL)
        vpi_release_handle(it);
    snprintf(buf, size, "%s %s", op_name(vpi_get(vpiOpType, ev)), name_of(operand));
}

static vpiHandle decl(PLI_INT32 type, const char *name)
{
    vpiHandle it = top ? vpi_iterate(type, top) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), name) == 0)
            found = h;
    if (found == NULL)
        vpi_printf((PLI_BYTE8 *)"%s not found\n", name);
    return found;
}

static vpiHandle property_expr(const char *name)
{
    vpiHandle d = decl(vpiPropertyDecl, name);
    vpiHandle spec = d ? vpi_handle(vpiPropertySpec, d) : NULL;
    vpiHandle e = spec ? vpi_handle(vpiPropertyExpr, spec) : NULL;
    if (d != NULL && e == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: no property expression\n", name);
    return e;
}

static vpiHandle sequence_expr(const char *name)
{
    vpiHandle d = decl(vpiSequenceDecl, name);
    vpiHandle e = d ? vpi_handle(vpiExpr, d) : NULL;
    if (d != NULL && e == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: no sequence expression\n", name);
    return e;
}

/* The operation type, the strength if asked, and the operands in order. */
static void operation(const char *name, vpiHandle e, int strength)
{
    vpiHandle it, h;

    if (e == NULL)
        return;
    if (vpi_get(vpiType, e) != vpiOperation) {
        vpi_printf((PLI_BYTE8 *)"%s: not an operation\n", name);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: %s", name, op_name(vpi_get(vpiOpType, e)));
    if (strength)
        vpi_printf((PLI_BYTE8 *)", strong %d", (int)vpi_get(vpiOpStrong, e));
    vpi_printf((PLI_BYTE8 *)", operands:");
    it = vpi_iterate(vpiOperand, e);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        print_operand(h);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void case_property(void)
{
    vpiHandle e = property_expr("p_case"), it, item, eit;
    char items[MAX][48];
    int n = 0, exprs, i;

    if (e == NULL)
        return;
    if (vpi_get(vpiType, e) != vpiCaseProperty) {
        vpi_printf((PLI_BYTE8 *)"p_case: not a case property\n");
        return;
    }
    it = vpi_iterate(vpiCasePropertyItem, e);
    while (it != NULL && (item = vpi_scan(it)) != NULL) {
        exprs = 0;
        eit = vpi_iterate(vpiExpr, item);
        while (eit != NULL && vpi_scan(eit) != NULL)
            exprs++;
        if (n < MAX)
            snprintf(items[n++], sizeof items[0], "%s: conditions %d",
                     name_of(vpi_handle(vpiPropertyExpr, item)), exprs);
    }
    qsort(items, (size_t)n, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"p_case: case on %s, items:", name_of(vpi_handle(vpiCondition, e)));
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", items[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void disabled_property(void)
{
    vpiHandle d = decl(vpiPropertyDecl, "p_dis");
    vpiHandle spec = d ? vpi_handle(vpiPropertySpec, d) : NULL;

    if (spec == NULL)
        return;
    vpi_printf((PLI_BYTE8 *)"p_dis: disable condition %s\n",
               name_of(vpi_handle(vpiDisableCondition, spec)));
    operation("p_dis", vpi_handle(vpiPropertyExpr, spec), 0);
}

static void clocked_properties(void)
{
    vpiHandle e = property_expr("p_clocked"), it, h, inner;
    char ev[48];
    int n = 0;

    if (e == NULL)
        return;
    vpi_printf((PLI_BYTE8 *)"p_clocked: %s, operands:",
               vpi_get(vpiType, e) == vpiOperation ? op_name(vpi_get(vpiOpType, e))
               : "not an operation");
    it = vpi_iterate(vpiOperand, e);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        vpi_printf((PLI_BYTE8 *)"%s", n++ ? "," : "");
        if (vpi_get(vpiType, h) != vpiClockedProp) {
            vpi_printf((PLI_BYTE8 *)" not a clocked property");
            continue;
        }
        event_text(vpi_handle(vpiClockingEvent, h), ev, sizeof ev);
        inner = vpi_handle(vpiPropertyExpr, h);
        vpi_printf((PLI_BYTE8 *)" clocked on %s", ev);
        print_operand(inner);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void three_clocks(void)
{
    vpiHandle e = sequence_expr("s_three_clocks"), it, h;
    char events[MAX][48];
    int n = 0, i;

    if (e == NULL)
        return;
    it = vpi_iterate(vpiClockedSeq, e);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            event_text(vpi_handle(vpiClockingEvent, h), events[n++], sizeof events[0]);
    qsort(events, (size_t)n, sizeof events[0], compare);
    /* The number of clocked sequences is not fixed; print each clock once. */
    vpi_printf((PLI_BYTE8 *)"s_three_clocks: multiclock %d, clocks of its clocked sequences:",
               vpi_get(vpiType, e) == vpiMulticlockSequenceExpr);
    for (i = 0; i < n; i++)
        if (i == 0 || strcmp(events[i], events[i - 1]) != 0)
            vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", events[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void let_objects(void)
{
    vpiHandle d = decl(vpiLetDecl, "mix"), it, h, ca = NULL, le, q_default = NULL;
    char formals[MAX][16];
    int n = 0, i;

    if (d == NULL)
        return;
    it = vpi_iterate(vpiSeqFormalDecl, d);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (strcmp(name_of(h), "q") == 0)
            q_default = vpi_handle(vpiExpr, h);
        if (n < MAX)
            snprintf(formals[n++], sizeof formals[0], "%s", name_of(h));
    }
    qsort(formals, (size_t)n, sizeof formals[0], compare);
    vpi_printf((PLI_BYTE8 *)"let %s: formals:", name_of(d));
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", formals[i]);
    if (q_default != NULL)
        vpi_printf((PLI_BYTE8 *)", default of q %d\n", int_value(q_default));
    else
        vpi_printf((PLI_BYTE8 *)", no default for q\n");
    it = top ? vpi_iterate(vpiContAssign, top) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        ca = h;
    le = ca ? vpi_handle(vpiRhs, ca) : NULL;
    if (le == NULL || vpi_get(vpiType, le) != vpiLetExpr) {
        vpi_printf((PLI_BYTE8 *)"the let expression was not found\n");
        return;
    }
    h = vpi_handle(vpiLetDecl, le);
    vpi_printf((PLI_BYTE8 *)"let expression: declaration is mix %d, value %d, arguments:",
               h != NULL && vpi_compare_objects(h, d) == 1, int_value(le));
    it = vpi_iterate(vpiArgument, le);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        print_operand(h);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 operators_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    operation("p_next", property_expr("p_next"), 1);
    operation("p_next2", property_expr("p_next2"), 1);
    operation("p_snext", property_expr("p_snext"), 1);
    operation("p_always", property_expr("p_always"), 1);
    operation("p_salways", property_expr("p_salways"), 1);
    operation("p_until", property_expr("p_until"), 1);
    operation("p_suntil", property_expr("p_suntil"), 1);
    case_property();
    disabled_property();
    clocked_properties();
    operation("s_udelay", sequence_expr("s_udelay"), 0);
    operation("s_goto", sequence_expr("s_goto"), 0);
    operation("s_nonconsec", sequence_expr("s_nonconsec"), 0);
    operation("s_throughout", sequence_expr("s_throughout"), 0);
    operation("s_within", sequence_expr("s_within"), 0);
    operation("s_first", sequence_expr("s_first"), 0);
    operation("s_intersect", sequence_expr("s_intersect"), 0);
    three_clocks();
    let_objects();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_operators";
    d.calltf = operators_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
