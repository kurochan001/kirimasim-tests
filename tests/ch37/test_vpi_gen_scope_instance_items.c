/* VPI application of test_vpi_gen_scope_instance_items (IEEE 1800-2023 37.85). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_gen_scope_instance_items"
#define MAX_NAMES 8

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *str_or(PLI_INT32 prop, vpiHandle h, const char *fallback)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    return s != NULL ? s : fallback;
}

/* How an item is named in the lists. */
static void item_text(vpiHandle h, char *buf, size_t size)
{
    char lhs[48];

    switch (vpi_get(vpiType, h)) {
    case vpiInitial:
        snprintf(buf, size, "initial");
        break;
    case vpiAlways:
    case vpiFinal:
        snprintf(buf, size, "other process");
        break;
    case vpiContAssign:
    case vpiAliasStmt:
        snprintf(lhs, sizeof lhs, "%s", str_or(vpiName, vpi_handle(vpiLhs, h), "?"));
        snprintf(buf, size, "%s = %s", lhs, str_or(vpiName, vpi_handle(vpiRhs, h), "?"));
        break;
    case vpiDefParam:
        snprintf(buf, size, "%s", str_or(vpiFullName, vpi_handle(vpiLhs, h), "?"));
        break;
    default:
        snprintf(buf, size, "%s", str_or(vpiName, h, "(no name)"));
        break;
    }
}

/* Prints the sorted items of vpi_iterate(relation, scope); returns the first. */
static vpiHandle list(const char *label, PLI_INT32 relation, const char *scope_name,
                      vpiHandle scope)
{
    char names[MAX_NAMES][96];
    vpiHandle it = scope != NULL ? vpi_iterate(relation, scope) : NULL, h, first = NULL;
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (first == NULL)
            first = h;
        if (n < MAX_NAMES)
            item_text(h, names[n++], sizeof names[0]);
    }
    qsort(names, (size_t)n, sizeof names[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s of %s:", label, scope_name);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s %s", i ? "," : "", names[i]);
    vpi_printf((PLI_BYTE8 *)"%s\n", n == 0 ? " none" : "");
    return first;
}

static void back(const char *label, vpiHandle h)
{
    vpiHandle gs = h != NULL ? vpi_handle(vpiGenScope, h) : NULL;

    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", label);
    else
        vpi_printf((PLI_BYTE8 *)"%s: gen scope %s\n", label, str_or(vpiFullName, gs, "NULL"));
}

static void back_by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    back(name, vpi_handle_by_name((PLI_BYTE8 *)full, NULL));
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle g1, g2, process, assign, defparam, alias;

    (void)data;
    g1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".g1", NULL);
    g2 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".g2", NULL);
    if (g1 == NULL || g2 == NULL || vpi_get(vpiType, g1) != vpiGenScope
        || vpi_get(vpiType, g2) != vpiGenScope) {
        vpi_printf((PLI_BYTE8 *)"g1 or g2 is not a gen scope\n");
        return 0;
    }
    process = list("process", vpiProcess, "g1", g1);
    assign = list("cont assign", vpiContAssign, "g1", g1);
    list("module", vpiModule, "g1", g1);
    list("primitive", vpiPrimitive, "g1", g1);
    defparam = list("def param", vpiDefParam, "g1", g1);
    list("gen scope array", vpiGenScopeArray, "g1", g1);
    list("program", vpiProgram, "g1", g1);
    list("interface", vpiInterface, "g1", g1);
    alias = list("alias stmt", vpiAliasStmt, "g1", g1);
    list("clocking block", vpiClockingBlock, "g1", g1);
    list("assertion", vpiAssertion, "g1", g1);
    list("module array", vpiModuleArray, "g2", g2);
    list("primitive array", vpiPrimitiveArray, "g2", g2);
    list("program array", vpiProgramArray, "g2", g2);
    list("interface array", vpiInterfaceArray, "g2", g2);

    back("the process of g1", process);
    back("the cont assign of g1", assign);
    back_by_name("g1.u_mod");
    back_by_name("g1.p_and");
    back("the def param of g1", defparam);
    back_by_name("g1.inner");
    back_by_name("g1.u_prg");
    back_by_name("g1.u_ifc");
    back("the alias stmt of g1", alias);
    back_by_name("g1.cb");
    back_by_name("g1.a_chk");
    back_by_name("g1.gt");
    back_by_name("g2.u_arr");
    back_by_name("g2.p_arr");
    back_by_name("g2.u_prga");
    back_by_name("g2.u_ifca");
    back_by_name("u_top");
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
