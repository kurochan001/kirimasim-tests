/* VPI application of test_vpi_gen_scope_array_relations (IEEE 1800-2023 37.85). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_gen_scope_array_relations"
#define MAX_NAMES 8

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void str_into(PLI_INT32 prop, vpiHandle h, char *buf, size_t size)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    snprintf(buf, size, "%s", h == NULL ? "NULL" : s != NULL ? s : "(no name)");
}

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s%s%s", TOP, name[0] ? "." : "", name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* Prints the sorted names of the gen scope arrays of ref. */
static void arrays_of(const char *label, vpiHandle ref)
{
    char names[MAX_NAMES][32];
    vpiHandle it = ref != NULL ? vpi_iterate(vpiGenScopeArray, ref) : NULL, h;
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX_NAMES)
            str_into(vpiName, h, names[n++], sizeof names[0]);
    qsort(names, (size_t)n, sizeof names[0], compare);
    vpi_printf((PLI_BYTE8 *)"gen scope arrays of %s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)"%s\n", n == 0 ? " none" : "");
}

static void array_props(const char *label, vpiHandle a, int with_module)
{
    char name[32], full[96], mod[96], inst[96];

    str_into(vpiName, a, name, sizeof name);
    str_into(vpiFullName, a, full, sizeof full);
    str_into(vpiFullName, a != NULL ? vpi_handle(vpiInstance, a) : NULL, inst, sizeof inst);
    if (with_module) {
        str_into(vpiFullName, a != NULL ? vpi_handle(vpiModule, a) : NULL, mod, sizeof mod);
        vpi_printf((PLI_BYTE8 *)"%s: name %s, full name %s, module %s, instance %s\n", label,
                   name, full, mod, inst);
    } else {
        vpi_printf((PLI_BYTE8 *)"%s: name %s, full name %s, instance %s\n", label, name, full,
                   inst);
    }
}

static void scope_props(const char *label, vpiHandle gs, int with_name)
{
    char name[32], arr[96];

    str_into(vpiName, gs, name, sizeof name);
    str_into(vpiFullName, gs != NULL ? vpi_handle(vpiGenScopeArray, gs) : NULL, arr, sizeof arr);
    if (with_name)
        vpi_printf((PLI_BYTE8 *)"%s: name %s, gen scope array %s, vpiArray %d\n", label, name,
                   arr, gs != NULL ? (int)vpi_get(vpiArray, gs) : -1);
    else
        vpi_printf((PLI_BYTE8 *)"%s: gen scope array %s, vpiArray %d\n", label, arr,
                   gs != NULL ? (int)vpi_get(vpiArray, gs) : -1);
}

static void element(const char *label, vpiHandle h)
{
    char full[96];
    str_into(vpiFullName, h, full, sizeof full);
    vpi_printf((PLI_BYTE8 *)"%s: %s\n", label, full);
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle top, ga, gsp, gv;
    char name[32], full[96];
    PLI_INT32 index[1];

    (void)data;
    top = by_name("");
    arrays_of("the module", top);
    arrays_of("u_ifc", by_name("u_ifc"));
    arrays_of("u_prog", by_name("u_prog"));

    ga = by_name("ga");
    array_props("ga", ga, 1);
    array_props("gd of gc[1]", by_name("gc[1].gd"), 1);
    array_props("ig of u_ifc", by_name("u_ifc.ig"), 0);
    array_props("pg of u_prog", by_name("u_prog.pg"), 0);

    gv = ga != NULL ? vpi_handle(vpiGenVar, ga) : NULL;
    str_into(vpiName, gv, name, sizeof name);
    str_into(vpiFullName, gv, full, sizeof full);
    vpi_printf((PLI_BYTE8 *)"gen var of ga: name %s, full name %s\n", name, full);
    arrays_of("the gen var of ga", gv);

    scope_props("ga[1]", by_name("ga[1]"), 0);
    scope_props("gc[1].gd[0]", by_name("gc[1].gd[0]"), 0);
    scope_props("gif", by_name("gif"), 1);
    scope_props("gcase", by_name("gcase"), 1);

    gsp = by_name("gsp");
    element("ga by index 2", ga != NULL ? vpi_handle_by_index(ga, 2) : NULL);
    index[0] = 1;
    element("ga by multi-index 1", ga != NULL ? vpi_handle_by_multi_index(ga, 1, index) : NULL);
    element("ga by index 5", ga != NULL ? vpi_handle_by_index(ga, 5) : NULL);
    element("gsp by index 4", gsp != NULL ? vpi_handle_by_index(gsp, 4) : NULL);
    element("gsp by index 1", gsp != NULL ? vpi_handle_by_index(gsp, 1) : NULL);
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
