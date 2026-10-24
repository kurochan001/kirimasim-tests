/* VPI application of test_vpi_program_relations (IEEE 1800-2023 37.9). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_program_relations"
#define MAX_ITEMS 8

static char items[MAX_ITEMS][128];
static int n_items;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void name_of(vpiHandle h, PLI_INT32 prop, char *buf, size_t size)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    snprintf(buf, size, "%s", h == NULL ? "NULL" : s != NULL ? s : "?");
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b);
}

/* Prints vpi_handle(rel) of `label` by the name property `prop`. */
static void one(const char *label, PLI_INT32 rel, const char *rel_name, PLI_INT32 prop)
{
    vpiHandle h = find(label);
    char name[96];

    name_of(h != NULL ? vpi_handle(rel, h) : NULL, prop, name, sizeof name);
    vpi_printf((PLI_BYTE8 *)"%s of %s: %s\n", rel_name, label, name);
}

/* What identifies an object: the type of a process, the target of a
   continuous assignment, the full name of anything else. */
static void describe(vpiHandle h, PLI_INT32 type, char *buf, size_t size)
{
    char lhs[48];

    if (type == vpiProcess) {
        name_of(h, vpiType, buf, size);
    } else if (type == vpiContAssign) {
        name_of(vpi_handle(vpiLhs, h), vpiName, lhs, sizeof lhs);
        snprintf(buf, size, "assignment to %s", lhs);
    } else {
        name_of(h, vpiFullName, buf, size);
    }
}

/* Iterates `type` from `label` and prints each object, sorted, with whether
   its vpiInstance is `label` when `check_instance` is 1. */
static void list(const char *label, PLI_INT32 type, const char *what, int check_instance)
{
    vpiHandle ref = find(label), it, h;
    char text[96];
    int i;

    n_items = 0;
    it = ref != NULL ? vpi_iterate(type, ref) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n_items == MAX_ITEMS)
            continue;
        describe(h, type, text, sizeof text);
        if (check_instance)
            snprintf(items[n_items++], sizeof items[0], "%s, vpiInstance is %s %d", text,
                     label, same(vpi_handle(vpiInstance, h), ref));
        else
            snprintf(items[n_items++], sizeof items[0], "%s", text);
    }
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s of %s: %d\n", what, label, n_items);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", items[i]);
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    one("p1", vpiDefaultClocking, "vpiDefaultClocking", vpiFullName);
    one("p2", vpiDefaultClocking, "vpiDefaultClocking", vpiFullName);
    one("q", vpiDefaultClocking, "vpiDefaultClocking", vpiFullName);
    one("p1", vpiDefaultDisableIff, "vpiDefaultDisableIff", vpiName);
    one("q", vpiDefaultDisableIff, "vpiDefaultDisableIff", vpiName);
    list("p1", vpiContAssign, "continuous assignments", 1);
    list("p2", vpiContAssign, "continuous assignments", 1);
    list("q", vpiContAssign, "continuous assignments", 1);
    list("p1", vpiClockingBlock, "clocking blocks", 1);
    list("p2", vpiClockingBlock, "clocking blocks", 1);
    list("q", vpiClockingBlock, "clocking blocks", 1);
    list("p1", vpiProcess, "processes", 1);
    list("p2", vpiProcess, "processes", 1);
    list("q", vpiProcess, "processes", 1);
    list("pa", vpiProgram, "programs", 0);
    one("pa[1]", vpiInstanceArray, "vpiInstanceArray", vpiFullName);
    one("p1", vpiInstanceArray, "vpiInstanceArray", vpiFullName);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
