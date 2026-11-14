/* VPI application of test_class_body_parameters_local_vpi (IEEE 1800-2023 8.3, 37.31). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_PARAMS 16
#define TOP "test_class_body_parameters_local_vpi"

struct param_flag {
    char name[64];
    int local;
};

static int compare_names(const void *a, const void *b)
{
    return strcmp(((const struct param_flag *)a)->name, ((const struct param_flag *)b)->name);
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

/* Prints the name and the vpiLocalParam flag of each parameter of the class
   defn called name, sorted by name. */
static void show_class(vpiHandle top, const char *name)
{
    struct param_flag list[MAX_PARAMS];
    int n = 0, i;
    vpiHandle cls = find_class(top, name);
    vpiHandle it = cls ? vpi_iterate(vpiParameter, cls) : NULL, h;
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (s == NULL || n == MAX_PARAMS)
            continue;
        snprintf(list[n].name, sizeof list[n].name, "%s", s);
        list[n++].local = (int)vpi_get(vpiLocalParam, h);
    }
    qsort(list, n, sizeof list[0], compare_names);
    vpi_printf((PLI_BYTE8 *)"%s:", name);
    if (cls == NULL)
        vpi_printf((PLI_BYTE8 *)" no class defn");
    else if (n == 0)
        vpi_printf((PLI_BYTE8 *)" no parameters");
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s local %d", list[i].name, list[i].local);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 class_param_flags_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    (void)user_data;
    show_class(top, "ported_c");
    show_class(top, "plain_c");
    return 0;
}

static void register_class_param_flags(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_class_param_flags";
    d.calltf = class_param_flags_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_class_param_flags, 0};

#ifdef __cplusplus
}
#endif
