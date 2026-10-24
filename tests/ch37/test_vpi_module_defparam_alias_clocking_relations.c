/* VPI application of test_vpi_module_defparam_alias_clocking_relations (IEEE 1800-2023 37.5). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_module_defparam_alias_clocking_relations"
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

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "?";
}

static void describe(vpiHandle h, PLI_INT32 type, char *buf, size_t size)
{
    char lhs[32];

    if (type == vpiDefParam) {
        snprintf(buf, size, "defparam of %s", name_of(vpi_handle(vpiLhs, h)));
    } else if (type == vpiAliasStmt) {
        snprintf(lhs, sizeof lhs, "%s", name_of(vpi_handle(vpiLhs, h)));
        snprintf(buf, size, "alias %s = %s", lhs, name_of(vpi_handle(vpiRhs, h)));
    } else {
        snprintf(buf, size, "clocking block %s", name_of(h));
    }
}

static void show(const char *label, PLI_INT32 type, const char *what)
{
    vpiHandle mod = find(label), it, h, back;
    const char *full;
    char text[48], owner[96];
    int i;

    n_items = 0;
    it = mod != NULL ? vpi_iterate(type, mod) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n_items == MAX_ITEMS)
            continue;
        describe(h, type, text, sizeof text);
        back = vpi_handle(vpiModule, h);
        full = back != NULL ? vpi_get_str(vpiFullName, back) : NULL;
        snprintf(owner, sizeof owner, "%s", back == NULL ? "NULL" : full != NULL ? full : "?");
        snprintf(items[n_items++], sizeof items[0], "%s, module %s, same instance %d", text,
                 owner, back != NULL && mod != NULL && vpi_compare_objects(back, mod));
    }
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s of %s: %d\n", what, *label ? label : "the top module", n_items);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", items[i]);
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    show("m1", vpiDefParam, "defparams");
    show("m2", vpiDefParam, "defparams");
    show("", vpiDefParam, "defparams");
    show("m1", vpiAliasStmt, "alias statements");
    show("m2", vpiAliasStmt, "alias statements");
    show("m1", vpiClockingBlock, "clocking blocks");
    show("m2", vpiClockingBlock, "clocking blocks");
    show("", vpiClockingBlock, "clocking blocks");
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
