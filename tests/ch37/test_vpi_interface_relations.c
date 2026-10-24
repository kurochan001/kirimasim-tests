/* VPI application of test_vpi_interface_relations (IEEE 1800-2023 37.6). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interface_relations"
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

/* Prints vpi_handle(rel) of the interface `label` by its name property
   `prop`. */
static void one(const char *label, PLI_INT32 rel, const char *rel_name, PLI_INT32 prop)
{
    vpiHandle h = find(label);
    char name[96];

    name_of(h != NULL ? vpi_handle(rel, h) : NULL, prop, name, sizeof name);
    vpi_printf((PLI_BYTE8 *)"%s of %s: %s\n", rel_name, label, name);
}

/* Iterates `type` from `label` and prints each object by its full name with
   whether vpiInstance of it is `label`. */
static void list(const char *label, PLI_INT32 type, const char *what)
{
    vpiHandle ref = find(label), it, h;
    char name[96];
    int i;

    n_items = 0;
    it = ref != NULL ? vpi_iterate(type, ref) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n_items == MAX_ITEMS)
            continue;
        name_of(h, vpiFullName, name, sizeof name);
        snprintf(items[n_items++], sizeof items[0], "%s, vpiInstance is %s %d", name, label,
                 same(vpi_handle(vpiInstance, h), ref));
    }
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s of %s: %d\n", what, label, n_items);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", items[i]);
}

/* Prints whether vpiInstance of `label` is `parent`. */
static void instance_of(const char *label, const char *parent)
{
    vpiHandle got = vpi_handle(vpiInstance, find(label));
    char name[96];

    name_of(got, vpiFullName, name, sizeof name);
    vpi_printf((PLI_BYTE8 *)"vpiInstance of %s: %s, is %s %d\n", label, name, parent,
               same(got, find(parent)));
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    one("o1", vpiGlobalClocking, "vpiGlobalClocking", vpiFullName);
    one("o2", vpiGlobalClocking, "vpiGlobalClocking", vpiFullName);
    one("p", vpiGlobalClocking, "vpiGlobalClocking", vpiFullName);
    one("o1", vpiDefaultDisableIff, "vpiDefaultDisableIff", vpiName);
    one("p", vpiDefaultDisableIff, "vpiDefaultDisableIff", vpiName);
    list("c1", vpiClockingBlock, "clocking blocks");
    list("p", vpiClockingBlock, "clocking blocks");
    list("o1", vpiInterfaceArray, "interface arrays");
    list("o2", vpiInterfaceArray, "interface arrays");
    list("p", vpiInterfaceArray, "interface arrays");
    instance_of("o1.n1", "o1");
    instance_of("o2.n1", "o2");
    instance_of("o1.gck", "o1");
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
