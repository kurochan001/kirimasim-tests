/* VPI application of test_vpi_module_port_io_decl_relations (IEEE 1800-2023 37.5). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_module_port_io_decl_relations"
#define MAX_ITEMS 8

struct item {
    int index;
    char name[32];
    char text[96];
};

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s%s%s", TOP, *name ? "." : "", name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *str_or(const char *s, const char *other)
{
    return s != NULL ? s : other;
}

static int by_index(const void *x, const void *y)
{
    const struct item *a = (const struct item *)x, *b = (const struct item *)y;
    return (a->index > b->index) - (a->index < b->index);
}

static int by_name(const void *x, const void *y)
{
    return strcmp(((const struct item *)x)->name, ((const struct item *)y)->name);
}

static const char *direction(PLI_INT32 d)
{
    switch (d) {
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other";
    }
}

/* Prints the objects of type `type` of module `label`, each with the full
   name of its vpiModule; ports are sorted by vpiPortIndex, IO declarations by
   name. */
static void show(const char *label, PLI_INT32 type)
{
    vpiHandle mod = find(label), it, h, back;
    struct item items[MAX_ITEMS];
    int n = 0, i;

    it = mod != NULL ? vpi_iterate(type, mod) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n == MAX_ITEMS)
            continue;
        back = vpi_handle(vpiModule, h);
        items[n].index = type == vpiPort ? (int)vpi_get(vpiPortIndex, h) : 0;
        snprintf(items[n].name, sizeof items[n].name, "%s",
                 str_or(vpi_get_str(vpiName, h), "?"));
        snprintf(items[n].text, sizeof items[n].text, "%s%s%s, module %s, same instance %d",
                 items[n].name, type == vpiIODecl ? " " : "",
                 type == vpiIODecl ? direction(vpi_get(vpiDirection, h)) : "",
                 back != NULL ? str_or(vpi_get_str(vpiFullName, back), "?") : "NULL",
                 back != NULL && mod != NULL && vpi_compare_objects(back, mod));
        n++;
    }
    qsort(items, (size_t)n, sizeof items[0], type == vpiPort ? by_index : by_name);
    vpi_printf((PLI_BYTE8 *)"%s of %s: %d\n", type == vpiPort ? "ports" : "io decls",
               *label ? label : "the top module", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", items[i].text);
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    show("u1", vpiPort);
    show("u2", vpiPort);
    show("", vpiPort);
    show("u1", vpiIODecl);
    show("", vpiIODecl);
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
