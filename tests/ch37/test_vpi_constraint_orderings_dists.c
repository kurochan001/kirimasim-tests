/* VPI application of test_vpi_constraint_orderings_dists (IEEE 1800-2023 37.34, 37.38). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_constraint_orderings_dists"
#define MAX 8

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* Prints the sorted names of the objects of an iteration. */
static void sorted_names(PLI_INT32 type, vpiHandle ref)
{
    vpiHandle it = ref != NULL ? vpi_iterate(type, ref) : NULL, h;
    char list[MAX][16];
    int n = 0, i;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            snprintf(list[n++], sizeof list[0], "%s", name_of(h));
    qsort(list, n, sizeof list[0], by_text);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", list[i]);
}

static int is_equality(vpiHandle h)
{
    return h != NULL && vpi_get(vpiType, h) == vpiOperation && vpi_get(vpiOpType, h) == vpiEqOp;
}

static const char *operator_of(vpiHandle h)
{
    if (vpi_get(vpiType, h) != vpiOperation)
        return "other";
    switch (vpi_get(vpiOpType, h)) {
    case vpiLtOp: return "<";
    case vpiGtOp: return ">";
    default: return "other";
    }
}

/* Prints the operator of each expression of vpiConstraintExpr, in order. */
static void expressions_in_order(vpiHandle item)
{
    vpiHandle it = vpi_iterate(vpiConstraintExpr, item), h;
    vpi_printf((PLI_BYTE8 *)", operators of the expressions in order:");
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        vpi_printf((PLI_BYTE8 *)" %s", operator_of(h));
}

static void distribution(vpiHandle d)
{
    vpiHandle it = vpi_iterate(vpiDistItem, d), item, vr;
    char list[MAX][32], value[16];
    int n = 0, i;

    vpi_printf((PLI_BYTE8 *)"distribution of %s, items:", name_of(vpi_handle(vpiExpr, d)));
    while (it != NULL && (item = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        vr = vpi_handle(vpiValueRange, item);
        if (vr != NULL && vpi_get(vpiType, vr) == vpiRange)
            snprintf(value, sizeof value, "[%d:%d]", int_value(vpi_handle(vpiLeftRange, vr)),
                     int_value(vpi_handle(vpiRightRange, vr)));
        else
            snprintf(value, sizeof value, "%d", int_value(vr));
        snprintf(list[n++], sizeof list[0], "%s %s %d", value,
                 vpi_get(vpiDistType, item) == vpiEqualDist ? ":=" :
                 vpi_get(vpiDistType, item) == vpiDivDist ? ":/" : "?",
                 int_value(vpi_handle(vpiWeight, item)));
    }
    qsort(list, n, sizeof list[0], by_text);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", list[i]);
}

static void describe(vpiHandle item, int position)
{
    switch (vpi_get(vpiType, item)) {
    case vpiConstraintOrdering:
        vpi_printf((PLI_BYTE8 *)"ordering, solve");
        sorted_names(vpiSolveBefore, item);
        vpi_printf((PLI_BYTE8 *)" before");
        sorted_names(vpiSolveAfter, item);
        break;
    case vpiDistribution:
        distribution(item);
        break;
    case vpiImplication:
        vpi_printf((PLI_BYTE8 *)"implication, condition is an equality %d",
                   is_equality(vpi_handle(vpiCondition, item)));
        expressions_in_order(item);
        break;
    case vpiConstrIf:
        vpi_printf((PLI_BYTE8 *)"constr if, condition is an equality %d",
                   is_equality(vpi_handle(vpiCondition, item)));
        expressions_in_order(item);
        break;
    case vpiSoftDisable:
        vpi_printf((PLI_BYTE8 *)"item %d disables soft constraints on %s", position,
                   name_of(vpi_handle(vpiExpr, item)));
        break;
    default:
        vpi_printf((PLI_BYTE8 *)"item %d soft %d", position, (int)vpi_get(vpiSoft, item));
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

static PLI_INT32 structure_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle defn = class_defn(), it, cons, items, item;
    int position;

    (void)user_data;
    it = defn != NULL ? vpi_iterate(vpiConstraint, defn) : NULL;
    if (it == NULL)
        vpi_printf((PLI_BYTE8 *)"no constraints\n");
    while (it != NULL && (cons = vpi_scan(it)) != NULL) {
        vpi_printf((PLI_BYTE8 *)"%s:", name_of(cons));
        items = vpi_iterate(vpiConstraintItem, cons);
        position = 0;
        while (items != NULL && (item = vpi_scan(items)) != NULL) {
            vpi_printf((PLI_BYTE8 *)"%s ", position ? "," : "");
            describe(item, ++position);
        }
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    return 0;
}

static PLI_INT32 enabled_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL), args, label, p, obj, it, cons, h;
    s_vpi_value v;
    int parent = 0;

    (void)user_data;
    args = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    label = args != NULL ? vpi_scan(args) : NULL;
    if (label != NULL) {
        vpi_release_handle(args);
        v.format = vpiStringVal;
        vpi_get_value(label, &v);
        vpi_printf((PLI_BYTE8 *)"%s:", v.value.str);
    }
    p = vpi_handle_by_name((PLI_BYTE8 *)TOP ".p", NULL);
    obj = p != NULL ? vpi_handle(vpiClassObj, p) : NULL;
    it = obj != NULL ? vpi_iterate(vpiConstraint, obj) : NULL;
    while (it != NULL && (cons = vpi_scan(it)) != NULL) {
        vpi_printf((PLI_BYTE8 *)" %s %d", name_of(cons),
                   (int)vpi_get(vpiIsConstraintEnabled, cons));
        h = vpi_handle(vpiParent, cons);
        parent += h != NULL && vpi_compare_objects(h, obj) ? 1 : 0;
    }
    vpi_printf((PLI_BYTE8 *)", parent is the object %d\n", parent);
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
    add("$vt_structure", structure_calltf);
    add("$vt_enabled", enabled_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
