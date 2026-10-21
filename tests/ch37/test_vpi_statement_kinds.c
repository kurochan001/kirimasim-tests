/* VPI application of test_vpi_statement_kinds (IEEE 1800-2023 37.60 to 37.79). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_statement_kinds"
#define MAX 8

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void append(char *buf, size_t size, const char *text)
{
    size_t len = strlen(buf);
    snprintf(buf + len, size - len, "%s", text);
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

/* A constant as its value, anything else by name. */
static void operand_text(vpiHandle h, char *buf, size_t size)
{
    char part[24];
    if (h != NULL && vpi_get(vpiType, h) == vpiConstant)
        snprintf(part, sizeof part, "%d", int_value(h));
    else
        snprintf(part, sizeof part, "%s", name_of(h));
    append(buf, size, part);
}

/* "posedge clk" for the condition of an event control. */
static void event_text(vpiHandle control, char *buf, size_t size)
{
    vpiHandle cond = control ? vpi_handle(vpiCondition, control) : NULL, it, operand = NULL;
    PLI_INT32 op;

    if (cond == NULL || vpi_get(vpiType, cond) != vpiOperation) {
        append(buf, size, name_of(cond));
        return;
    }
    op = vpi_get(vpiOpType, cond);
    it = vpi_iterate(vpiOperand, cond);
    if (it != NULL && (operand = vpi_scan(it)) != NULL)
        vpi_release_handle(it);
    append(buf, size, op == vpiPosedgeOp ? "posedge " : op == vpiNegedgeOp ? "negedge " : "? ");
    append(buf, size, name_of(operand));
}

static const char *operator_text(PLI_INT32 op)
{
    switch (op) {
    case vpiAssignmentOp: return "=";
    case vpiSubOp: return "-=";
    case vpiBitOrOp: return "|=";
    case vpiArithLShiftOp: return "<<<=";
    default: return "other operator";
    }
}

/* A bit-select with its index, or a concatenation with its operands. */
static void lhs_text(vpiHandle lhs, char *buf, size_t size)
{
    char part[32], names[MAX][16];
    vpiHandle it, h, index;
    int n = 0, i;

    if (lhs == NULL) {
        append(buf, size, "none");
    } else if (vpi_get(vpiType, lhs) == vpiBitSelect) {
        index = vpi_handle(vpiIndex, lhs);
        snprintf(part, sizeof part, "bit-select with index %d", index ? int_value(index) : -1);
        append(buf, size, part);
    } else if (vpi_get(vpiType, lhs) == vpiOperation && vpi_get(vpiOpType, lhs) == vpiConcatOp) {
        append(buf, size, "concatenation of, sorted:");
        it = vpi_iterate(vpiOperand, lhs);
        while (it != NULL && (h = vpi_scan(it)) != NULL)
            if (n < MAX)
                snprintf(names[n++], sizeof names[0], "%s", name_of(h));
        qsort(names, (size_t)n, sizeof names[0], compare);
        for (i = 0; i < n; i++) {
            append(buf, size, " ");
            append(buf, size, names[i]);
        }
    } else {
        append(buf, size, "other expression");
    }
}

static void assignment_text(vpiHandle s, char *buf, size_t size)
{
    char part[48];
    vpiHandle ec = vpi_handle(vpiEventControl, s), rc = vpi_handle(vpiRepeatControl, s);

    snprintf(part, sizeof part, "assignment %s %s ", name_of(vpi_handle(vpiLhs, s)),
             operator_text(vpi_get(vpiOpType, s)));
    append(buf, size, part);
    operand_text(vpi_handle(vpiRhs, s), buf, size);
    if (rc != NULL) {
        append(buf, size, ", repeat control ");
        operand_text(vpi_handle(vpiExpr, rc), buf, size);
        append(buf, size, " times on ");
        event_text(vpi_handle(vpiEventControl, rc), buf, size);
    } else if (ec != NULL) {
        append(buf, size, ", event control ");
        event_text(ec, buf, size);
        append(buf, size, vpi_handle(vpiStmt, ec) == NULL ? " with no statement"
               : " with a statement");
    }
}

/* The patterns of the items of a case matches, sorted. */
static void pattern_items(vpiHandle c, char *buf, size_t size)
{
    char items[MAX][64];
    vpiHandle it = vpi_iterate(vpiCaseItem, c), item, eit, p, sub;
    int n = 0, i;

    while (it != NULL && (item = vpi_scan(it)) != NULL) {
        eit = vpi_iterate(vpiExpr, item);
        while (eit != NULL && (p = vpi_scan(eit)) != NULL) {
            if (n == MAX)
                continue;
            if (vpi_get(vpiType, p) != vpiTaggedPattern) {
                snprintf(items[n++], sizeof items[0], "other pattern");
                continue;
            }
            sub = vpi_handle(vpiPattern, p);
            snprintf(items[n++], sizeof items[0], "tagged pattern with %s",
                     sub == NULL ? "no pattern" : "a pattern");
        }
    }
    qsort(items, (size_t)n, sizeof items[0], compare);
    for (i = 0; i < n; i++) {
        append(buf, size, i ? "; " : "");
        append(buf, size, items[i]);
    }
}

static void stmt_text(vpiHandle s, char *buf, size_t size)
{
    PLI_INT32 q;
    int items = 0;
    vpiHandle it;

    switch (vpi_get(vpiType, s)) {
    case vpiAssignment:
        assignment_text(s, buf, size);
        break;
    case vpiCase:
        if (vpi_get(vpiCaseType, s) == vpiCaseX) {
            q = vpi_get(vpiQualifier, s);
            it = vpi_iterate(vpiCaseItem, s);
            while (it != NULL && vpi_scan(it) != NULL)
                items++;
            append(buf, size, "case, type casex, qualifier ");
            append(buf, size, q == vpiPriorityQualifier ? "priority" : "other");
            append(buf, size, ", condition ");
            append(buf, size, name_of(vpi_handle(vpiCondition, s)));
            append(buf, size, items == 2 ? ", 2 items" : ", other number of items");
        } else {
            append(buf, size, "case matches: ");
            pattern_items(s, buf, size);
        }
        break;
    case vpiForce:
        append(buf, size, "force, lhs ");
        lhs_text(vpi_handle(vpiLhs, s), buf, size);
        append(buf, size, ", rhs ");
        operand_text(vpi_handle(vpiRhs, s), buf, size);
        break;
    case vpiRelease:
        append(buf, size, "release, lhs ");
        lhs_text(vpi_handle(vpiLhs, s), buf, size);
        break;
    case vpiAssignStmt:
        append(buf, size, "assign, lhs ");
        lhs_text(vpi_handle(vpiLhs, s), buf, size);
        append(buf, size, ", rhs ");
        operand_text(vpi_handle(vpiRhs, s), buf, size);
        break;
    case vpiDeassign:
        append(buf, size, "deassign, lhs ");
        lhs_text(vpi_handle(vpiLhs, s), buf, size);
        break;
    default:
        append(buf, size, "other statement");
    }
}

static void processes(vpiHandle top)
{
    char lines[MAX][128];
    vpiHandle it = vpi_iterate(vpiProcess, top), p, s;
    PLI_INT32 kind;
    int n = 0, i;

    while (it != NULL && (p = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, p) != vpiAlways || n == MAX)
            continue;
        kind = vpi_get(vpiAlwaysType, p);
        s = vpi_handle(vpiStmt, p);
        lines[n][0] = '\0';
        append(lines[n], sizeof lines[0], kind == vpiAlwaysFF ? "always_ff: "
               : kind == vpiAlwaysLatch ? "always_latch: " : "other always: ");
        if (s != NULL && vpi_get(vpiType, s) == vpiEventControl) {
            append(lines[n], sizeof lines[0], "event control ");
            event_text(s, lines[n], sizeof lines[0]);
        } else if (s != NULL && vpi_get(vpiType, s) == vpiIf) {
            append(lines[n], sizeof lines[0], "if on ");
            append(lines[n], sizeof lines[0], name_of(vpi_handle(vpiCondition, s)));
        } else {
            append(lines[n], sizeof lines[0], "other statement");
        }
        n++;
    }
    qsort(lines, (size_t)n, sizeof lines[0], compare);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
}

#define STMTS 16

static PLI_INT32 stmts_calltf(PLI_BYTE8 *user_data)
{
    static char lines[STMTS][200];
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".stmts", NULL);
    vpiHandle body = task ? vpi_handle(vpiStmt, task) : NULL, it, s;
    const char *label;
    int n = 0, i;

    (void)user_data;
    if (top != NULL)
        processes(top);
    if (body == NULL || vpi_get(vpiType, body) != vpiBegin) {
        vpi_printf((PLI_BYTE8 *)"the body of stmts is not an unnamed begin\n");
        return 0;
    }
    /* No sentence fixes the order of the vpiStmt iteration: print sorted. */
    it = vpi_iterate(vpiStmt, body);
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        if (n == STMTS)
            continue;
        label = vpi_get_str(vpiName, s);
        snprintf(lines[n], sizeof lines[0], "label %s: ", label != NULL ? label : "none");
        stmt_text(s, lines[n], sizeof lines[0]);
        n++;
    }
    qsort(lines, (size_t)n, sizeof lines[0], compare);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_stmts";
    d.calltf = stmts_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
