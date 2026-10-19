/* VPI application of test_vpi_module_hierarchy (IEEE 1800-2023 37.10, 38.23). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_ITEMS 32

/* vpi_get_str returns a buffer that the next call reuses (38.11), so names are
   copied before they are compared or printed together. */
static char *str_of(PLI_INT32 property, vpiHandle h)
{
    const char *s = vpi_get_str(property, h);
    char *copy = (char *)malloc(strlen(s) + 1);
    strcpy(copy, s);
    return copy;
}

struct item {
    vpiHandle handle;
    char *name;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

static int collect(vpiHandle mod, PLI_INT32 type, struct item *items)
{
    vpiHandle it = vpi_iterate(type, mod);
    vpiHandle h;
    int n = 0;
    if (it == NULL)
        return 0;
    while ((h = vpi_scan(it)) != NULL) {
        items[n].handle = h;
        items[n].name = str_of(vpiName, h);
        n++;
    }
    qsort(items, n, sizeof items[0], by_name);
    return n;
}

static void walk(vpiHandle mod, int depth)
{
    struct item items[MAX_ITEMS];
    char *full = str_of(vpiFullName, mod);
    int n, i;

    vpi_printf("%*smodule %s (%s)\n", 2 * depth, "", full, vpi_get_str(vpiDefName, mod));
    n = collect(mod, vpiNet, items);
    for (i = 0; i < n; i++)
        vpi_printf("%*snet %s, %d bits\n",
                   2 * depth + 2, "", items[i].name, (int)vpi_get(vpiSize, items[i].handle));
    n = collect(mod, vpiReg, items);
    for (i = 0; i < n; i++)
        vpi_printf("%*sreg %s, %d bits\n",
                   2 * depth + 2, "", items[i].name, (int)vpi_get(vpiSize, items[i].handle));
    n = collect(mod, vpiModule, items);
    for (i = 0; i < n; i++)
        walk(items[i].handle, depth + 1);
}

static vpiHandle first_arg(void)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle h = vpi_scan(it);
    vpi_free_object(it);
    return h;
}

static PLI_INT32 walk_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    walk(first_arg(), 0);
    return 0;
}

static PLI_INT32 lookup_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;
    vpiHandle obj;
    char *name, *scope;
    (void)user_data;
    v.format = vpiStringVal;
    vpi_get_value(first_arg(), &v);
    obj = vpi_handle_by_name(v.value.str, NULL);
    /* Both names are copied first: the order in which the arguments of a
       call are evaluated is unspecified. */
    name = str_of(vpiFullName, obj);
    scope = str_of(vpiFullName, vpi_handle(vpiModule, obj));
    vpi_printf("%s: %d bits, in %s\n", name, (int)vpi_get(vpiSize, obj), scope);
    return 0;
}

static void register_all(void)
{
{
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.sysfunctype = 0;
        d.tfname = (PLI_BYTE8 *)"$vt_walk";
        d.calltf = walk_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
    {
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.sysfunctype = 0;
        d.tfname = (PLI_BYTE8 *)"$vt_lookup";
        d.calltf = lookup_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
