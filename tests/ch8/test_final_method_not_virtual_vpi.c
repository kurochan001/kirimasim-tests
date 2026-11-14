/* VPI application of test_final_method_not_virtual_vpi (IEEE 1800-2023 8.20, 37.41). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Annex M gives vpiMethods the value 730 and vpiVirtual the value 635; a
   header without them gets them here. */
#ifndef vpiMethods
#define vpiMethods 730
#endif
#ifndef vpiVirtual
#define vpiVirtual 635
#endif

#define MAX_METHODS 16
#define TOP "test_final_method_not_virtual_vpi"

struct method_flag {
    char name[64];
    int is_virtual;
};

static int compare_names(const void *a, const void *b)
{
    return strcmp(((const struct method_flag *)a)->name, ((const struct method_flag *)b)->name);
}

/* The class defn called name among the class defns of the instance top, or NULL. */
static vpiHandle find_class(vpiHandle top, const char *name)
{
    vpiHandle it = top ? vpi_iterate(vpiClassDefn, top) : NULL, h, found = NULL;
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (found == NULL && s != NULL && strcmp(s, name) == 0)
            found = h;
    }
    return found;
}

/* Prints the name and the vpiVirtual flag of each method declared in the
   class defn called name, sorted by name. Only methods whose vpiFullName
   starts with the full name of the class defn and :: (37.41 detail 5) are
   printed, so that a method of base_c is never printed for leaf_c. A
   constructor is left out: the classes do not declare one. */
static void show_class(vpiHandle top, const char *name)
{
    struct method_flag list[MAX_METHODS];
    char prefix[256] = "";
    int n = 0, i;
    vpiHandle cls = find_class(top, name);
    vpiHandle it = cls ? vpi_iterate(vpiMethods, cls) : NULL, h;
    if (cls != NULL && vpi_get_str(vpiFullName, cls) != NULL)
        snprintf(prefix, sizeof prefix, "%s::", vpi_get_str(vpiFullName, cls));
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *full = vpi_get_str(vpiFullName, h), *s;
        if (n == MAX_METHODS || full == NULL || strncmp(full, prefix, strlen(prefix)) != 0)
            continue;
        s = vpi_get_str(vpiName, h);
        if (s == NULL || strcmp(s, "new") == 0)
            continue;
        snprintf(list[n].name, sizeof list[n].name, "%s", s);
        list[n++].is_virtual = (int)vpi_get(vpiVirtual, h);
    }
    qsort(list, n, sizeof list[0], compare_names);
    vpi_printf((PLI_BYTE8 *)"%s:", name);
    if (cls == NULL)
        vpi_printf((PLI_BYTE8 *)" no class defn");
    else if (n == 0)
        vpi_printf((PLI_BYTE8 *)" no methods");
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s virtual %d", list[i].name, list[i].is_virtual);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 method_virtual_flags_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    (void)user_data;
    show_class(top, "base_c");
    show_class(top, "leaf_c");
    return 0;
}

static void register_method_virtual_flags(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_method_virtual_flags";
    d.calltf = method_virtual_flags_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_method_virtual_flags, 0};

#ifdef __cplusplus
}
#endif
