/* VPI application of test_vpi_module_internal_scope_relations (IEEE 1800-2023 37.5). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_module_internal_scope_relations"
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

static const char *str_or(const char *s, const char *other)
{
    return s != NULL ? s : other;
}

static void show(const char *label)
{
    vpiHandle mod = find(label), it, h, back;
    char text[48], owner[80];
    int i;

    n_items = 0;
    it = mod != NULL ? vpi_iterate(vpiInternalScope, mod) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n_items == MAX_ITEMS)
            continue;
        snprintf(text, sizeof text, "%s", str_or(vpi_get_str(vpiName, h), "?"));
        snprintf(text + strlen(text), sizeof text - strlen(text), " %s",
                 str_or(vpi_get_str(vpiType, h), "?"));
        back = vpi_handle(vpiModule, h);
        snprintf(owner, sizeof owner, "%s",
                 back != NULL ? str_or(vpi_get_str(vpiFullName, back), "?") : "NULL");
        snprintf(items[n_items++], sizeof items[0], "%s, module %s, same instance %d", text,
                 owner, back != NULL && mod != NULL && vpi_compare_objects(back, mod));
    }
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"internal scopes of %s: %d\n", label, n_items);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", items[i]);
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    show("s1");
    show("s2");
    show("e");
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
