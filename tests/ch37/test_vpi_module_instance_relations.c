/* VPI application of test_vpi_module_instance_relations (IEEE 1800-2023 37.5, 37.6). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_module_instance_relations"
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
    snprintf(full, sizeof full, "%s%s%s", TOP, *name ? "." : "", name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void full_name(vpiHandle h, char *buf, size_t size)
{
    const char *s = h != NULL ? vpi_get_str(vpiFullName, h) : NULL;
    snprintf(buf, size, "%s", h == NULL ? "NULL" : s != NULL ? s : "?");
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b);
}

/* Iterates `type` from the object `label` and prints each object with the
   full name of its vpiModule, compared with `owner_label`, or only its full
   name when `with_owner` is 0. */
static void list(const char *label, PLI_INT32 type, const char *what, int with_owner)
{
    vpiHandle ref = find(label), it, h, back;
    char name[96], owner[96];
    int i;

    n_items = 0;
    it = ref != NULL ? vpi_iterate(type, ref) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n_items == MAX_ITEMS)
            continue;
        full_name(h, name, sizeof name);
        if (with_owner) {
            back = vpi_handle(vpiModule, h);
            full_name(back, owner, sizeof owner);
            snprintf(items[n_items++], sizeof items[0], "%s, module %s, same instance %d", name,
                     owner, same(back, ref));
        } else {
            snprintf(items[n_items++], sizeof items[0], "%s", name);
        }
    }
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s of %s: %d\n", what, label, n_items);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", items[i]);
}

/* Prints vpi_handle(rel) of `label`, compared with `expected_label`, which
   is "" when NULL is expected. */
static void one(const char *label, PLI_INT32 rel, const char *rel_name,
                const char *expected_label)
{
    vpiHandle h = find(label), got = h != NULL ? vpi_handle(rel, h) : NULL;
    char name[96];

    full_name(got, name, sizeof name);
    vpi_printf((PLI_BYTE8 *)"%s of %s: %s, as expected %d\n", rel_name, *label ? label : TOP,
               name, *expected_label ? same(got, find(expected_label)) : got == NULL);
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    list("m1", vpiInterface, "interfaces", 1);
    list("m2", vpiInterface, "interfaces", 1);
    one("m1.l1", vpiModule, "vpiModule", "m1");
    one("m2.l1", vpiModule, "vpiModule", "m2");
    one("", vpiModule, "vpiModule", "");
    list("a1", vpiInterfaceArray, "interface arrays", 1);
    list("a1", vpiModuleArray, "module arrays", 1);
    list("a1.la", vpiModule, "modules", 0);
    list("a1.ba", vpiInterface, "interfaces", 0);
    one("a1.la[1]", vpiInstanceArray, "vpiInstanceArray", "a1.la");
    one("a1.la[1]", vpiModuleArray, "vpiModuleArray", "a1.la");
    one("a1.ba[0]", vpiInstanceArray, "vpiInstanceArray", "a1.ba");
    one("m1.l1", vpiInstanceArray, "vpiInstanceArray", "");
    one("m1.l1", vpiModuleArray, "vpiModuleArray", "");
    one("m1.b1", vpiInstanceArray, "vpiInstanceArray", "");
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
