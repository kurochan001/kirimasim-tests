/* VPI application of test_vpi_gen_scope_data_items (IEEE 1800-2023 37.85). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_gen_scope_data_items"
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

/* Prints the sorted names of vpi_iterate(relation, ref). */
static void list(const char *label, PLI_INT32 relation, vpiHandle ref)
{
    char names[MAX_NAMES][32];
    vpiHandle it = ref != NULL ? vpi_iterate(relation, ref) : NULL, h;
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX_NAMES)
            snprintf(names[n++], sizeof names[0], "%s", str_or(vpiName, h, "(no name)"));
    qsort(names, (size_t)n, sizeof names[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s of g:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)"%s\n", n == 0 ? " none" : "");
}

static void back(const char *label, vpiHandle h)
{
    vpiHandle gs = h != NULL ? vpi_handle(vpiGenScope, h) : NULL;

    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", label);
        return;
    }
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
    vpiHandle g, it, h, ts = NULL;

    (void)data;
    g = vpi_handle_by_name((PLI_BYTE8 *)TOP ".g", NULL);
    if (g == NULL || vpi_get(vpiType, g) != vpiGenScope) {
        vpi_printf((PLI_BYTE8 *)"g is not a gen scope\n");
        return 0;
    }
    list("net", vpiNet, g);
    list("array net", vpiArrayNet, g);
    list("logic var", vpiLogicVar, g);
    list("array var", vpiArrayVar, g);
    list("memory", vpiMemory, g);
    list("variables", vpiVariables, g);
    list("named event", vpiNamedEvent, g);
    list("named event array", vpiNamedEventArray, g);
    list("typedef", vpiTypedef, g);

    back_by_name("g.w");
    back_by_name("g.na");
    back_by_name("g.lv");
    back_by_name("g.av");
    back_by_name("g.iv");
    back_by_name("g.ev");
    back_by_name("g.eva");
    back_by_name("g.P");
    it = vpi_iterate(vpiTypedef, g);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(str_or(vpiName, h, ""), "tri_t") == 0)
            ts = h;
    back("typedef tri_t", ts);
    back_by_name("top_w");
    back_by_name("top_v");
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
