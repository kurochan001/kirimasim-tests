/* VPI application of test_parameter_keyword_local_contexts_vpi (IEEE 1800-2023 6.20.1, 37.28). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Annex M gives vpiUnit the value 602; a header without it gets it here. */
#ifndef vpiUnit
#define vpiUnit 602
#endif

#define MAX 8
#define TOP "test_parameter_keyword_local_contexts_vpi"
#define PKG "test_parameter_keyword_local_contexts_vpi_pkg"
#define UNIT_P "test_parameter_keyword_local_contexts_vpi_unit_p"

struct flag {
    char name[64];
    int local;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct flag *)a)->name, ((const struct flag *)b)->name);
}

/* Adds the parameters of scope to list, only the one called only if it is
   not NULL, and returns the new length. */
static int collect(vpiHandle scope, const char *only, struct flag *list, int n)
{
    vpiHandle it = scope ? vpi_iterate(vpiParameter, scope) : NULL, h;
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (s == NULL || n == MAX || (only && strcmp(s, only) != 0))
            continue;
        snprintf(list[n].name, sizeof list[n].name, "%s", s);
        list[n++].local = (int)vpi_get(vpiLocalParam, h);
    }
    return n;
}

static void print(const char *label, struct flag *list, int n)
{
    int i;
    qsort(list, n, sizeof list[0], by_name);
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none");
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s local %d", list[i].name, list[i].local);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void show_scope(const char *label, const char *path)
{
    struct flag list[MAX];
    print(label, list, collect(vpi_handle_by_name((PLI_BYTE8 *)path, NULL), NULL, list, 0));
}

/* The class definition called name among those of the instance top. */
static vpiHandle class_defn(vpiHandle top, const char *name)
{
    vpiHandle it = top ? vpi_iterate(vpiClassDefn, top) : NULL, h, found = NULL;
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (found == NULL && s && strcmp(s, name) == 0)
            found = h;
    }
    return found;
}

static PLI_INT32 local_flags_calltf(PLI_BYTE8 *user_data)
{
    struct flag list[MAX];
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), it, h;
    int n_pkg = 0, n_unit = 0;
    struct flag unit_list[MAX];

    (void)user_data;
    show_scope("module with a parameter port list", TOP ".u1");
    show_scope("module with an empty parameter port list", TOP ".u2");
    show_scope("module without a parameter port list", TOP ".u3");
    show_scope("generate block", TOP ".u3.g");
    show_scope("interface with a parameter port list", TOP ".i1");
    show_scope("program with a parameter port list", TOP ".p1");
    print("class with a parameter port list", list,
          collect(class_defn(top, "pc_c"), NULL, list, 0));
    print("class without a parameter port list", list,
          collect(class_defn(top, "nc_c"), NULL, list, 0));
    it = vpi_iterate(vpiInstance, NULL);
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s;
        if (vpi_get(vpiType, h) != vpiPackage)
            continue;
        s = vpi_get_str(vpiName, h);
        if (vpi_get(vpiUnit, h))
            n_unit = collect(h, UNIT_P, unit_list, n_unit);
        else if (s && strcmp(s, PKG) == 0)
            n_pkg = collect(h, NULL, list, n_pkg);
    }
    print("package", list, n_pkg);
    print("compilation unit", unit_list, n_unit);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_local_flags";
    d.calltf = local_flags_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
