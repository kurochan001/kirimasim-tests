/* VPI application of test_vpi_for_expect_children (IEEE 1800-2023 37.73, 37.74). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_for_expect_children"
#define MAX_LINES 8
#define MAX_PARTS 4

static char lines[MAX_LINES][256];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *op_text(PLI_INT32 op)
{
    switch (op) {
    case vpiLtOp: return "<";
    case vpiPosedgeOp: return "posedge";
    case vpiNegedgeOp: return "negedge";
    default: return "?";
    }
}

/* NULL as none, a constant as its value, "x < y" for a binary operation,
   "posedge x" for an edge, anything else by name. */
static void expr_text(vpiHandle h, char *buf, size_t size)
{
    char left[32], right[32];
    vpiHandle it, l, r;
    const char *s;

    if (h == NULL) {
        snprintf(buf, size, "none");
    } else if (vpi_get(vpiType, h) == vpiConstant) {
        snprintf(buf, size, "%d", int_value(h));
    } else if (vpi_get(vpiType, h) == vpiOperation) {
        it = vpi_iterate(vpiOperand, h);
        l = it != NULL ? vpi_scan(it) : NULL;
        r = l != NULL ? vpi_scan(it) : NULL;
        if (r != NULL && vpi_scan(it) != NULL)
            vpi_release_handle(it);
        expr_text(l, left, sizeof left);
        if (r == NULL) {
            snprintf(buf, size, "%s %s", op_text(vpi_get(vpiOpType, h)), left);
        } else {
            expr_text(r, right, sizeof right);
            snprintf(buf, size, "%s %s %s", left, op_text(vpi_get(vpiOpType, h)), right);
        }
    } else {
        s = vpi_get_str(vpiName, h);
        snprintf(buf, size, "%s", s != NULL ? s : "unnamed expression");
    }
}

/* An assignment as "x = 1", "x += 1" or "x -= 1", NULL as none. */
static void stmt_text(vpiHandle s, char *buf, size_t size)
{
    char lhs[32], rhs[32];
    PLI_INT32 op;

    if (s == NULL) {
        snprintf(buf, size, "none");
        return;
    }
    if (vpi_get(vpiType, s) != vpiAssignment) {
        snprintf(buf, size, "other statement");
        return;
    }
    expr_text(vpi_handle(vpiLhs, s), lhs, sizeof lhs);
    expr_text(vpi_handle(vpiRhs, s), rhs, sizeof rhs);
    op = vpi_get(vpiOpType, s);
    snprintf(buf, size, "%s %s %s", lhs,
             op == vpiAssignmentOp ? "=" : op == vpiAddOp ? "+=" : op == vpiSubOp ? "-=" : "?=",
             rhs);
}

/* The statements of an iteration, sorted and separated by commas. */
static void stmt_list(PLI_INT32 relation, vpiHandle ref, char *buf, size_t size)
{
    char parts[MAX_PARTS][32];
    vpiHandle it = vpi_iterate(relation, ref), h;
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX_PARTS)
            stmt_text(h, parts[n++], sizeof parts[0]);
    qsort(parts, (size_t)n, sizeof parts[0], compare);
    buf[0] = '\0';
    for (i = 0; i < n; i++) {
        size_t len = strlen(buf);
        snprintf(buf + len, size - len, "%s%s", i ? ", " : "", parts[i]);
    }
    if (n == 0)
        snprintf(buf, size, "none");
}

static void describe_for(vpiHandle s)
{
    char body[32], cond[32], inits[80], incs[80], init1[32], inc1[32];
    int local = vpi_get(vpiLocalVarDecls, s) != 0;

    stmt_text(vpi_handle(vpiStmt, s), body, sizeof body);
    expr_text(vpi_handle(vpiCondition, s), cond, sizeof cond);
    stmt_list(vpiForIncStmt, s, incs, sizeof incs);
    if (strcmp(body, "v = 100") == 0) {
        stmt_list(vpiForInitStmt, s, inits, sizeof inits);
        snprintf(lines[line_count++], sizeof lines[0],
                 "%s: for, local variables %d, condition %s, initializations [%s], steps [%s]",
                 body, local, cond, inits, incs);
    } else if (strcmp(body, "v = 200") == 0) {
        stmt_list(vpiForInitStmt, s, inits, sizeof inits);
        stmt_text(vpi_handle(vpiForInitStmt, s), init1, sizeof init1);
        stmt_text(vpi_handle(vpiForIncStmt, s), inc1, sizeof inc1);
        snprintf(lines[line_count++], sizeof lines[0],
                 "%s: for, local variables %d, condition %s, initialization %s [%s], step %s [%s]",
                 body, local, cond, init1, inits, inc1, incs);
    } else {
        snprintf(lines[line_count++], sizeof lines[0],
                 "%s: for, local variables %d, condition %s, steps [%s]", body, local, cond, incs);
    }
}

static void describe_expect(vpiHandle s)
{
    char body[32], other[32], clock[32], disable[32];
    vpiHandle spec = vpi_handle(vpiPropertySpec, s);

    stmt_text(vpi_handle(vpiStmt, s), body, sizeof body);
    stmt_text(vpi_handle(vpiElseStmt, s), other, sizeof other);
    expr_text(spec != NULL ? vpi_handle(vpiClockingEvent, spec) : NULL, clock, sizeof clock);
    expr_text(spec != NULL ? vpi_handle(vpiDisableCondition, spec) : NULL, disable,
              sizeof disable);
    snprintf(lines[line_count++], sizeof lines[0],
             "%s: expect, property spec %s with clock %s and disable %s, else %s",
             body, spec != NULL ? "found" : "NULL", clock, disable, other);
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, it, s;
    int n = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".stmts", NULL);
    body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL;
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        n++;
        if (line_count == MAX_LINES)
            continue;
        if (vpi_get(vpiType, s) == vpiFor)
            describe_for(s);
        else if (vpi_get(vpiType, s) == vpiExpectStmt)
            describe_expect(s);
        else
            snprintf(lines[line_count++], sizeof lines[0], "other statement");
    }
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"statements: %d\n", n);
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
