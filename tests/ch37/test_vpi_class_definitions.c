/* VPI application of test_vpi_class_definitions (IEEE 1800-2023 37.31, 37.32). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_ITEMS 8

static char items[MAX_ITEMS][48];
static int n_items;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_or_none(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "(none)";
}

/* Collects the names (with the local flag for parameters) of a relation. */
static void collect(PLI_INT32 type, vpiHandle ref, int sorted, const char *label)
{
    vpiHandle it = vpi_iterate(type, ref), h;
    int i;

    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL && n_items < MAX_ITEMS) {
            if (type == vpiParameter)
                snprintf(items[n_items++], sizeof items[0], "%s(local %d)", name_or_none(h),
                         (int)vpi_get(vpiLocalParam, h));
            else
                snprintf(items[n_items++], sizeof items[0], "%s", name_or_none(h));
        }
    if (sorted)
        qsort(items, (size_t)n_items, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s%s:", type == vpiClassDefn ? "" : "  ", label);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)" %s", items[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
    n_items = 0;
}

static vpiHandle find_class(const char *name)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_class_definitions", NULL);
    vpiHandle it = vpi_iterate(vpiClassDefn, top), h, found = NULL;

    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL)
            if (found == NULL && strcmp(name_or_none(h), name) == 0)
                found = h;
    return found;
}

static PLI_INT32 classes_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_class_definitions", NULL);
    vpiHandle base, shape, square, ext;

    (void)user_data;
    collect(vpiClassDefn, top, 1, "class definitions");
    base = find_class("base");
    shape = find_class("shape");
    square = find_class("square");
    if (base == NULL || shape == NULL || square == NULL) {
        vpi_printf((PLI_BYTE8 *)"a class definition is missing\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"base: virtual %d\n", (int)vpi_get(vpiVirtual, base));
    collect(vpiVariables, base, 1, "variables");
    collect(vpiMethods, base, 1, "methods");
    collect(vpiConstraint, base, 0, "constraints in order");
    collect(vpiParameter, base, 1, "parameters");
    vpi_printf((PLI_BYTE8 *)"shape: virtual %d\n", (int)vpi_get(vpiVirtual, shape));
    collect(vpiDerivedClasses, shape, 1, "derived classes");
    ext = vpi_handle(vpiExtends, square);
    vpi_printf((PLI_BYTE8 *)"square: virtual %d, extends %s\n", (int)vpi_get(vpiVirtual, square),
               ext ? name_or_none(vpi_handle(vpiClassTypespec, ext)) : "(no extends)");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_classes";
    d.calltf = classes_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
