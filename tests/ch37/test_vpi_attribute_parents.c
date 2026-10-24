/* VPI application of test_vpi_attribute_parents (IEEE 1800-2023 37.83). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_attribute_parents"
#define MAX_ATTRS 4

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* The first object of vpi_iterate(relation, ref). */
static vpiHandle first_of(PLI_INT32 relation, vpiHandle ref)
{
    vpiHandle it = ref != NULL ? vpi_iterate(relation, ref) : NULL, h;

    if (it == NULL)
        return NULL;
    h = vpi_scan(it);
    if (h != NULL)
        vpi_release_handle(it);
    return h;
}

/* Prints "label: name=value (vpiParent is it: 1), ..." for the attributes of obj. */
static void attributes(const char *label, vpiHandle obj)
{
    char attrs[MAX_ATTRS][64];
    vpiHandle it, a, parent;
    s_vpi_value v;
    const char *name;
    int n = 0, i;

    if (obj == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", label);
        return;
    }
    it = vpi_iterate(vpiAttribute, obj);
    while (it != NULL && (a = vpi_scan(it)) != NULL) {
        if (n == MAX_ATTRS)
            continue;
        name = vpi_get_str(vpiName, a);
        v.format = vpiIntVal;
        vpi_get_value(a, &v);
        parent = vpi_handle(vpiParent, a);
        snprintf(attrs[n++], sizeof attrs[0], "%s=%d (vpiParent is it: %d)",
                 name != NULL ? name : "(no name)", (int)v.value.integer,
                 parent != NULL && vpi_compare_objects(parent, obj) ? 1 : 0);
    }
    qsort(attrs, (size_t)n, sizeof attrs[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", attrs[i]);
    vpi_printf((PLI_BYTE8 *)"%s\n", n == 0 ? " none" : "");
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle top, task, stmt, cls;

    (void)data;
    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    attributes("module instance u", by_name("u"));
    attributes("net w", by_name("w"));
    attributes("net w_plain", by_name("w_plain"));
    attributes("net array wa", by_name("wa"));
    attributes("variable iv", by_name("iv"));
    attributes("named event e", by_name("e"));
    attributes("specparam SP", by_name("SP"));
    attributes("task t_attr", by_name("t_attr"));
    attributes("primitive g1", by_name("g1"));
    task = by_name("t_stmt");
    stmt = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    attributes("statement of t_stmt", stmt);
    attributes("operation on its right-hand side", stmt != NULL ? vpi_handle(vpiRhs, stmt) : NULL);
    attributes("process of the module", first_of(vpiProcess, top));
    attributes("sequence s1", by_name("s1"));
    attributes("property p1", by_name("p1"));
    attributes("assertion a1", by_name("a1"));
    attributes("clocking block cb", by_name("cb"));
    cls = first_of(vpiClassDefn, top);
    attributes("class defn of the module", cls);
    attributes("constraint of the class", first_of(vpiConstraint, cls));
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
