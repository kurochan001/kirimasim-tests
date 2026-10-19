/* VPI application of test_vpi_generate_scopes (IEEE 1800-2023 37.85). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_generate_scopes"
#define MAX 8

struct named {
    char name[64];
    vpiHandle h;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct named *)a)->name, ((const struct named *)b)->name);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *name_of(vpiHandle h, PLI_INT32 prop)
{
    PLI_BYTE8 *s = h ? vpi_get_str(prop, h) : NULL;
    return h == NULL ? "NULL" : s ? s : "(null)";
}

/* The value of the local parameter i inside a gen scope, or -1. */
static int genvar_value(vpiHandle scope)
{
    vpiHandle it = vpi_iterate(vpiParameter, scope), p;
    int value = -1;
    while (it && (p = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, p);
        if (s && strcmp(s, "i") == 0 && vpi_get(vpiLocalParam, p) == 1)
            value = int_value(p);
    }
    return value;
}

static PLI_INT32 generate_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle g = vpi_handle_by_name((PLI_BYTE8 *)TOP ".g", NULL), it, h, r, x, scope;
    struct named list[MAX];
    int n = 0, i;

    (void)user_data;
    if (g == NULL) {
        vpi_printf("g not found\n");
        return 0;
    }
    vpi_printf("g: %s, size %d, gen var %s\n",
               vpi_get(vpiType, g) == vpiGenScopeArray ? "gen scope array" : "other type",
               (int)vpi_get(vpiSize, g), name_of(vpi_handle(vpiGenVar, g), vpiName));
    it = vpi_iterate(vpiGenScope, g);
    while (it && (h = vpi_scan(it)) != NULL)
        if (n < MAX) {
            snprintf(list[n].name, sizeof list[n].name, "%s", name_of(h, vpiFullName));
            list[n++].h = h;
        }
    qsort(list, n, sizeof list[0], by_name);
    for (i = 0; i < n; i++) {
        vpiHandle index = vpi_handle(vpiIndex, list[i].h);
        vpi_printf("%s: %s, array member %d, index %d, implicit %d, local parameter i = %d\n",
                   list[i].name,
                   vpi_get(vpiType, list[i].h) == vpiGenScope ? "gen scope" : "other type",
                   (int)vpi_get(vpiArrayMember, list[i].h), index ? int_value(index) : -1,
                   (int)vpi_get(vpiImplicitDecl, list[i].h), genvar_value(list[i].h));
    }
    h = vpi_handle_by_index(g, 1);
    vpi_printf("g by index 1: %s\n", name_of(h, vpiFullName));
    r = vpi_handle_by_name((PLI_BYTE8 *)TOP ".g[1].r", NULL);
    vpi_printf("g[1].r: size %d\n", r ? (int)vpi_get(vpiSize, r) : -1);
    x = vpi_handle_by_name((PLI_BYTE8 *)TOP ".genblk2.x", NULL);
    scope = x ? vpi_handle(vpiScope, x) : NULL;
    vpi_printf("scope of x: %s, %s, implicit %d\n", name_of(scope, vpiFullName),
               scope && vpi_get(vpiType, scope) == vpiGenScope ? "gen scope" : "other type",
               scope ? (int)vpi_get(vpiImplicitDecl, scope) : -1);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_generate";
    d.calltf = generate_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
