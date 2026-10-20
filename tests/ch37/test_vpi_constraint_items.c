/* VPI application of test_vpi_constraint_items (IEEE 1800-2023 37.34, 37.38). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_constraint_items"

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int count(PLI_INT32 type, vpiHandle ref)
{
    vpiHandle it = vpi_iterate(type, ref);
    int n = 0;
    while (it != NULL && vpi_scan(it) != NULL)
        n++;
    return n;
}

static vpiHandle find_class(void)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top ? vpi_iterate(vpiClassDefn, top) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), "packet") == 0)
            found = h;
    return found;
}

static const char *item_kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiConstrForEach: return "foreach";
    case vpiConstrIfElse: return "if-else";
    case vpiConstrIf: return "if";
    case vpiImplication: return "implication";
    default: return "expression";
    }
}

static void loop_vars(vpiHandle fe)
{
    vpiHandle it = vpi_iterate(vpiLoopVars, fe), v;
    while (it != NULL && (v = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, v) == vpiOperation && vpi_get(vpiOpType, v) == vpiNullOp)
            vpi_printf((PLI_BYTE8 *)" (skipped)");
        else
            vpi_printf((PLI_BYTE8 *)" %s", name_of(v));
    }
}

static PLI_INT32 constraints_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle cls = find_class(), it, c, items, item;

    (void)user_data;
    if (cls == NULL) {
        vpi_printf((PLI_BYTE8 *)"class packet not found\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"constraints:");
    it = vpi_iterate(vpiConstraint, cls);
    while (it != NULL && (c = vpi_scan(it)) != NULL)
        vpi_printf((PLI_BYTE8 *)" %s(automatic %d, extern %d)", name_of(c),
                   (int)vpi_get(vpiAutomatic, c), vpi_get(vpiAccessType, c) == vpiExternAcc);
    vpi_printf((PLI_BYTE8 *)"\n");
    it = vpi_iterate(vpiConstraint, cls);
    while (it != NULL && (c = vpi_scan(it)) != NULL) {
        if (strcmp(name_of(c), "c_second") != 0 && strcmp(name_of(c), "c_skip") != 0)
            continue;
        items = vpi_iterate(vpiConstraintItem, c);
        while (items != NULL && (item = vpi_scan(items)) != NULL) {
            vpi_printf((PLI_BYTE8 *)"%s: %s", name_of(c), item_kind(item));
            if (vpi_get(vpiType, item) == vpiConstrForEach) {
                vpi_printf((PLI_BYTE8 *)" over %s, index", name_of(vpi_handle(vpiVariables, item)));
                loop_vars(item);
                vpi_printf((PLI_BYTE8 *)", %d expression", count(vpiConstraintExpr, item));
            } else if (vpi_get(vpiType, item) == vpiConstrIfElse) {
                vpi_printf((PLI_BYTE8 *)", condition %s, %d then, %d else",
                           vpi_handle(vpiCondition, item) ? "given" : "none",
                           count(vpiConstraintExpr, item), count(vpiElseConst, item));
            }
            vpi_printf((PLI_BYTE8 *)"\n");
        }
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
    add("$vt_constraints", constraints_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
