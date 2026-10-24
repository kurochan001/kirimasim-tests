/* VPI application of test_vpi_variable_driver_load_kinds (IEEE 1800-2023 37.17, 37.21). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_driver_load_kinds"

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

/* Counts the objects of the relation, those that are continuous assignments,
   and those of which var is the vpiLhs (side vpiLhs) or the vpiRhs. */
static void assignments(const char *label, PLI_INT32 rel, const char *name, PLI_INT32 side)
{
    vpiHandle var = find(name);
    vpiHandle it = var ? vpi_iterate(rel, var) : NULL, h;
    int n = 0, ca = 0, on_side = 0;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        n++;
        if (vpi_get(vpiType, h) == vpiContAssign) {
            ca++;
            if (same(vpi_handle(side, h), var))
                on_side++;
        }
    }
    vpi_printf("%s of %s: %d, cont assigns %d, with %s as %s %d\n", label, name, n, ca, name,
               side == vpiLhs ? "vpiLhs" : "vpiRhs", on_side);
}

static vpiHandle term_of_g1(int index)
{
    vpiHandle g1 = find("g1");
    vpiHandle it = g1 ? vpi_iterate(vpiPrimTerm, g1) : NULL, t, found = NULL;
    while (it != NULL && (t = vpi_scan(it)) != NULL)
        if (found == NULL && vpi_get(vpiTermIndex, t) == index)
            found = t;
    return found;
}

static void terminals(const char *name)
{
    vpiHandle var = find(name);
    vpiHandle it = var ? vpi_iterate(vpiPrimTerm, var) : NULL, t;
    int n = 0;

    vpi_printf("prim terms of %s:", name);
    while (it != NULL && (t = vpi_scan(it)) != NULL) {
        int index = (int)vpi_get(vpiTermIndex, t);
        n++;
        vpi_printf(" [index %d, input %d, terminal %d of g1 %d]", index,
                   vpi_get(vpiDirection, t) == vpiInput ? 1 : 0, index,
                   same(t, term_of_g1(index)));
    }
    vpi_printf(" (%d)\n", n);
}

static PLI_INT32 dl_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (find("v1") == NULL || find("g1") == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    assignments("drivers", vpiDriver, "v1", vpiLhs);
    assignments("cont assigns", vpiContAssign, "v1", vpiLhs);
    assignments("loads", vpiLoad, "v1", vpiRhs);
    assignments("loads", vpiLoad, "v2", vpiRhs);
    assignments("drivers", vpiDriver, "v2", vpiLhs);
    assignments("drivers", vpiDriver, "v4", vpiLhs);
    assignments("cont assigns", vpiContAssign, "v4", vpiLhs);
    terminals("v3");
    terminals("a");
    terminals("v4");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_dl";
    d.calltf = dl_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
