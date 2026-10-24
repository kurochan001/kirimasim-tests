/* VPI application of test_vpi_loop_branch_children (IEEE 1800-2023 37.66 to 37.78). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_loop_branch_children"
#define MAX_LINES 16

static char lines[MAX_LINES][160];
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

/* NULL as none, a constant as its value, x + y for an addition, else the name. */
static void expr_text(vpiHandle h, char *buf, size_t size)
{
    char left[48], right[48];
    vpiHandle it, l, r;
    const char *s;

    if (h == NULL) {
        snprintf(buf, size, "none");
    } else if (vpi_get(vpiType, h) == vpiConstant) {
        snprintf(buf, size, "%d", int_value(h));
    } else if (vpi_get(vpiType, h) == vpiOperation) {
        if (vpi_get(vpiOpType, h) != vpiAddOp) {
            snprintf(buf, size, "other operation");
            return;
        }
        it = vpi_iterate(vpiOperand, h);
        l = it != NULL ? vpi_scan(it) : NULL;
        r = l != NULL ? vpi_scan(it) : NULL;
        if (r != NULL && vpi_scan(it) != NULL) {
            vpi_release_handle(it);
            snprintf(buf, size, "addition with more than two operands");
            return;
        }
        expr_text(l, left, sizeof left);
        expr_text(r, right, sizeof right);
        snprintf(buf, size, "%s + %s", left, right);
    } else {
        s = vpi_get_str(vpiName, h);
        snprintf(buf, size, "%s", s != NULL ? s : "unnamed expression");
    }
}

/* An assignment as "v = N", NULL as none. */
static void stmt_text(vpiHandle s, char *buf, size_t size)
{
    char lhs[48], rhs[48];

    if (s == NULL) {
        snprintf(buf, size, "none");
    } else if (vpi_get(vpiType, s) == vpiAssignment) {
        expr_text(vpi_handle(vpiLhs, s), lhs, sizeof lhs);
        expr_text(vpi_handle(vpiRhs, s), rhs, sizeof rhs);
        snprintf(buf, size, "%s = %s", lhs, rhs);
    } else {
        snprintf(buf, size, "other statement");
    }
}

static void describe(vpiHandle s)
{
    char cond[48], body[48], other[48];
    char *line;
    size_t size = sizeof lines[0];

    if (line_count == MAX_LINES)
        return;
    line = lines[line_count++];
    switch (vpi_get(vpiType, s)) {
    case vpiWhile:
    case vpiRepeat:
    case vpiDoWhile:
        expr_text(vpi_handle(vpiCondition, s), cond, sizeof cond);
        stmt_text(vpi_handle(vpiStmt, s), body, sizeof body);
        snprintf(line, size, "%s: condition %s, statement %s",
                 vpi_get(vpiType, s) == vpiWhile ? "while"
                 : vpi_get(vpiType, s) == vpiRepeat ? "repeat" : "do-while", cond, body);
        break;
    case vpiForever:
    case vpiForeachStmt:
        stmt_text(vpi_handle(vpiStmt, s), body, sizeof body);
        snprintf(line, size, "%s: statement %s",
                 vpi_get(vpiType, s) == vpiForever ? "forever" : "foreach", body);
        break;
    case vpiIf:
        expr_text(vpi_handle(vpiCondition, s), cond, sizeof cond);
        stmt_text(vpi_handle(vpiStmt, s), body, sizeof body);
        snprintf(line, size, "if: condition %s, qualifier %d, statement %s",
                 cond, (int)vpi_get(vpiQualifier, s), body);
        break;
    case vpiIfElse:
        expr_text(vpi_handle(vpiCondition, s), cond, sizeof cond);
        stmt_text(vpi_handle(vpiStmt, s), body, sizeof body);
        stmt_text(vpi_handle(vpiElseStmt, s), other, sizeof other);
        snprintf(line, size, "if-else: condition %s, qualifier %d, statement %s, else %s",
                 cond, (int)vpi_get(vpiQualifier, s), body, other);
        break;
    case vpiReturnStmt:
        expr_text(vpi_handle(vpiCondition, s), cond, sizeof cond);
        snprintf(line, size, "return: condition %s", cond);
        break;
    default:
        snprintf(line, size, "other statement");
        break;
    }
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, func, ret, it, s;
    char cond[48];
    int n = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".bodies", NULL);
    body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL;
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        n++;
        describe(s);
    }
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"statements of bodies: %d\n", n);

    func = vpi_handle_by_name((PLI_BYTE8 *)TOP ".plus_one", NULL);
    ret = func != NULL ? vpi_handle(vpiStmt, func) : NULL;
    if (ret == NULL || vpi_get(vpiType, ret) != vpiReturnStmt) {
        vpi_printf((PLI_BYTE8 *)"plus_one: no return statement\n");
    } else {
        expr_text(vpi_handle(vpiCondition, ret), cond, sizeof cond);
        vpi_printf((PLI_BYTE8 *)"plus_one: return, condition %s\n", cond);
    }
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
