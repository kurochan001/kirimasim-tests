/* VPI application of test_vpi_constraint_expr_contents (IEEE 1800-2023 37.38, 37.34). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_constraint_expr_contents"
#define LEN 256

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "(none)";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *op_symbol(vpiHandle h)
{
    switch (vpi_get(vpiOpType, h)) {
    case vpiLtOp: return "<";
    case vpiGtOp: return ">";
    case vpiEqOp: return "==";
    case vpiNeqOp: return "!=";
    default: return "?";
    }
}

/* A binary relation as "left op right"; a constant operand is printed as its
 * value and, with names set, another operand as its name. */
static void expr_text(vpiHandle e, int names, char *out, size_t len)
{
    vpiHandle it, op;
    int n = 0;

    if (e == NULL) {
        snprintf(out, len, "NULL");
        return;
    }
    if (vpi_get(vpiType, e) != vpiOperation) {
        snprintf(out, len, "(not an operation)");
        return;
    }
    out[0] = '\0';
    it = vpi_iterate(vpiOperand, e);
    while (it != NULL && (op = vpi_scan(it)) != NULL) {
        if (n == 1)
            snprintf(out + strlen(out), len - strlen(out), "%s%s", strlen(out) ? " " : "",
                     op_symbol(e));
        if (vpi_get(vpiType, op) == vpiConstant)
            snprintf(out + strlen(out), len - strlen(out), "%s%d", strlen(out) ? " " : "",
                     int_value(op));
        else if (names)
            snprintf(out + strlen(out), len - strlen(out), "%s%s", strlen(out) ? " " : "",
                     name_of(op));
        n++;
    }
}

static void expr_list(vpiHandle item, PLI_INT32 rel, int names, char *out, size_t len)
{
    vpiHandle it = vpi_iterate(rel, item), e;
    char one[64];
    int n = 0;

    out[0] = '\0';
    while (it != NULL && (e = vpi_scan(it)) != NULL) {
        expr_text(e, names, one, sizeof one);
        snprintf(out + strlen(out), len - strlen(out), "%s%s", n++ ? ", " : "", one);
    }
    if (n == 0)
        snprintf(out, len, "none");
}

static void item_detail(vpiHandle item)
{
    char cond[64], then_part[128], else_part[128];
    vpiHandle it, di, back;
    int n = 0, same = 0;

    switch (vpi_get(vpiType, item)) {
    case vpiConstrIfElse:
        expr_text(vpi_handle(vpiCondition, item), 1, cond, sizeof cond);
        expr_list(item, vpiConstraintExpr, 1, then_part, sizeof then_part);
        expr_list(item, vpiElseConst, 1, else_part, sizeof else_part);
        vpi_printf((PLI_BYTE8 *)"  if-else: condition %s; then: %s; else: %s\n", cond, then_part,
                   else_part);
        break;
    case vpiConstrIf:
        expr_text(vpi_handle(vpiCondition, item), 1, cond, sizeof cond);
        expr_list(item, vpiConstraintExpr, 1, then_part, sizeof then_part);
        vpi_printf((PLI_BYTE8 *)"  if: condition %s; then: %s\n", cond, then_part);
        break;
    case vpiImplication:
        expr_text(vpi_handle(vpiCondition, item), 1, cond, sizeof cond);
        expr_list(item, vpiConstraintExpr, 1, then_part, sizeof then_part);
        vpi_printf((PLI_BYTE8 *)"  implication: condition %s; then: %s\n", cond, then_part);
        break;
    case vpiConstrForEach:
        expr_list(item, vpiConstraintExpr, 0, then_part, sizeof then_part);
        vpi_printf((PLI_BYTE8 *)"  foreach: %s\n", then_part);
        break;
    case vpiDistribution:
        it = vpi_iterate(vpiDistItem, item);
        while (it != NULL && (di = vpi_scan(it)) != NULL) {
            back = vpi_handle(vpiDistribution, di);
            if (back != NULL && vpi_compare_objects(back, item))
                same++;
            n++;
        }
        vpi_printf((PLI_BYTE8 *)"  distribution of %s: dist items leading back to it %d of %d\n",
                   name_of(vpi_handle(vpiExpr, item)), same, n);
        break;
    default:
        expr_text(item, 1, cond, sizeof cond);
        vpi_printf((PLI_BYTE8 *)"  expression %s\n", cond);
        break;
    }
}

static vpiHandle class_defn(void)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top != NULL ? vpi_iterate(vpiClassDefn, top) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (found == NULL && strcmp(name_of(h), "pkt") == 0)
            found = h;
    return found;
}

static PLI_INT32 constraints_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle defn = class_defn(), it, cons, items, item;
    PLI_INT32 access;
    char acc[24], cname[32];

    (void)user_data;
    it = defn != NULL ? vpi_iterate(vpiConstraint, defn) : NULL;
    if (it == NULL)
        vpi_printf((PLI_BYTE8 *)"no constraints\n");
    while (it != NULL && (cons = vpi_scan(it)) != NULL) {
        access = vpi_get(vpiAccessType, cons);
        if (access == vpiExternAcc)
            snprintf(acc, sizeof acc, "vpiExternAcc");
        else
            snprintf(acc, sizeof acc, "%d", (int)access);
        /* vpi_get_str can reuse its buffer, so the name is copied first. */
        snprintf(cname, sizeof cname, "%s", name_of(cons));
        vpi_printf((PLI_BYTE8 *)"%s: full name %s, access %s\n", cname,
                   vpi_get_str(vpiFullName, cons) ? vpi_get_str(vpiFullName, cons) : "(none)",
                   acc);
        items = vpi_iterate(vpiConstraintItem, cons);
        while (items != NULL && (item = vpi_scan(items)) != NULL)
            item_detail(item);
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_constraints";
    d.calltf = constraints_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
