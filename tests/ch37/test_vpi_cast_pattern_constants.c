/* VPI application of test_vpi_cast_pattern_constants (IEEE 1800-2023 37.59). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_cast_pattern_constants"
#define MAX_LINES 16

static char lines[MAX_LINES][192];
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

static const char *name_or(vpiHandle h, const char *fallback)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : fallback;
}

static const char *const_type(vpiHandle h)
{
    switch (vpi_get(vpiConstType, h)) {
    case vpiDecConst: return "vpiDecConst";
    case vpiRealConst: return "vpiRealConst";
    case vpiBinaryConst: return "vpiBinaryConst";
    case vpiOctConst: return "vpiOctConst";
    case vpiHexConst: return "vpiHexConst";
    case vpiStringConst: return "vpiStringConst";
    case vpiIntConst: return "vpiIntConst";
    case vpiNullConst: return "vpiNullConst";
    default: return "other constant type";
    }
}

/* The kind of a typespec, with its name when with_name is set. */
static void typespec_text(vpiHandle t, int with_name, char *buf, size_t size)
{
    const char *kind;

    if (t == NULL) {
        snprintf(buf, size, "none");
        return;
    }
    switch (vpi_get(vpiType, t)) {
    case vpiIntTypespec: kind = "int typespec"; break;
    case vpiLogicTypespec: kind = "logic typespec"; break;
    case vpiStructTypespec: kind = "struct typespec"; break;
    default: kind = "other typespec"; break;
    }
    if (with_name)
        snprintf(buf, size, "%s %s", kind, name_or(t, "(no name)"));
    else
        snprintf(buf, size, "%s", kind);
}

/* A constant as its value, a pattern with its operands, else the name. */
static void expr_text(vpiHandle h, char *buf, size_t size)
{
    char part[64];
    vpiHandle it, op;
    PLI_INT32 type;
    int n = 0;
    size_t len;

    if (h == NULL) {
        snprintf(buf, size, "none");
        return;
    }
    if (vpi_get(vpiType, h) == vpiConstant) {
        snprintf(buf, size, "%d", int_value(h));
        return;
    }
    if (vpi_get(vpiType, h) != vpiOperation) {
        snprintf(buf, size, "%s", name_or(h, "unnamed expression"));
        return;
    }
    type = vpi_get(vpiOpType, h);
    snprintf(buf, size, "%s (",
             type == vpiAssignmentPatternOp ? "assignment pattern"
             : type == vpiMultiAssignmentPatternOp ? "multi-assignment pattern"
             : type == vpiCastOp ? "cast" : "other operation");
    it = vpi_iterate(vpiOperand, h);
    while (it != NULL && (op = vpi_scan(it)) != NULL) {
        expr_text(op, part, sizeof part);
        len = strlen(buf);
        snprintf(buf + len, size - len, "%s%s", n++ ? ", " : "", part);
    }
    len = strlen(buf);
    snprintf(buf + len, size - len, ")");
}

static void describe(vpiHandle s)
{
    char target[16], rhs_text[96], ts[48];
    vpiHandle rhs;
    PLI_INT32 type;
    int with_name;

    if (line_count == MAX_LINES)
        return;
    if (vpi_get(vpiType, s) != vpiAssignment) {
        snprintf(lines[line_count++], sizeof lines[0], "other statement");
        return;
    }
    snprintf(target, sizeof target, "%s", name_or(vpi_handle(vpiLhs, s), "?"));
    rhs = vpi_handle(vpiRhs, s);
    expr_text(rhs, rhs_text, sizeof rhs_text);
    type = rhs != NULL ? vpi_get(vpiType, rhs) : 0;
    with_name = strcmp(target, "w1") == 0 || strcmp(target, "t2") == 0;
    if (type == vpiConstant) {
        if (strcmp(target, "k_real") == 0 || strcmp(target, "k_null") == 0)
            snprintf(lines[line_count++], sizeof lines[0], "%s = constant %s", target,
                     const_type(rhs));
        else
            snprintf(lines[line_count++], sizeof lines[0], "%s = constant %s, size %d", target,
                     const_type(rhs), (int)vpi_get(vpiSize, rhs));
    } else if (type == vpiOperation && vpi_get(vpiOpType, rhs) == vpiCastOp) {
        typespec_text(vpi_handle(vpiTypespec, rhs), with_name, ts, sizeof ts);
        snprintf(lines[line_count++], sizeof lines[0], "%s = %s, typespec %s, size %d", target,
                 rhs_text, ts, (int)vpi_get(vpiSize, rhs));
    } else if (strcmp(target, "t2") == 0 || strcmp(target, "s8") == 0) {
        typespec_text(vpi_handle(vpiTypespec, rhs), with_name, ts, sizeof ts);
        snprintf(lines[line_count++], sizeof lines[0], "%s = %s, typespec %s", target,
                 rhs_text, ts);
    } else {
        snprintf(lines[line_count++], sizeof lines[0], "%s = %s", target, rhs_text);
    }
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle task, body, it, s;
    int n = 0, i;

    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".exprs", NULL);
    body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL;
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        n++;
        describe(s);
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
