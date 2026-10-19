/* VPI application of test_vpi_scopes (IEEE 1800-2023 37.12, 37.41, 37.13). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_scopes"
#define MAX 8

struct named {
    char name[16];
    vpiHandle h;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct named *)a)->name, ((const struct named *)b)->name);
}

static int collect(vpiHandle it, struct named *list)
{
    vpiHandle h;
    int n = 0;
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (n == MAX)
            continue;
        snprintf(list[n].name, sizeof list[n].name, "%s", s ? s : "(null)");
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    return n;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiNamedBegin: return "named begin";
    case vpiNamedFork: return "named fork";
    case vpiTask: return "task";
    case vpiFunction: return "function";
    default: return "other type";
    }
}

static const char *direction(vpiHandle h)
{
    switch (vpi_get(vpiDirection, h)) {
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other direction";
    }
}

static void list_scopes(const char *label, vpiHandle scope)
{
    struct named list[MAX];
    int n = scope ? collect(vpi_iterate(vpiInternalScope, scope), list) : 0, i;
    vpi_printf("scopes of %s:", label);
    for (i = 0; i < n; i++)
        vpi_printf("%s %s %s", i ? "," : "", list[i].name, kind(list[i].h));
    vpi_printf("\n");
}

static vpiHandle find(const char *name)
{
    char full[64];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name(full, NULL);
}

static PLI_INT32 scopes_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle blk = find("blk"), v = find("blk.v"), tk = find("tk"), fn = find("fn");
    vpiHandle vf = find("vf"), ret;
    struct named list[MAX];
    int n, i;

    (void)user_data;
    list_scopes("the module", vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL));
    list_scopes("blk", blk);
    vpi_printf("scope of blk.v is blk: %d\n",
               v && blk ? (int)vpi_compare_objects(vpi_handle(vpiScope, v), blk) : -1);
    if (tk == NULL || fn == NULL || vf == NULL) {
        vpi_printf("a task or function was not found\n");
        return 0;
    }
    vpi_printf("automatic: tk %d, fn %d\n", (int)vpi_get(vpiAutomatic, tk),
               (int)vpi_get(vpiAutomatic, fn));
    ret = vpi_handle(vpiReturn, fn);
    vpi_printf("size: fn %d, its return variable %d, vf %d\n", (int)vpi_get(vpiSize, fn),
               ret ? (int)vpi_get(vpiSize, ret) : -1, (int)vpi_get(vpiSize, vf));
    n = collect(vpi_iterate(vpiIODecl, tk), list);
    vpi_printf("io declarations of tk:");
    for (i = 0; i < n; i++)
        vpi_printf("%s %s %s %d", i ? "," : "", list[i].name, direction(list[i].h),
                   (int)vpi_get(vpiSize, list[i].h));
    vpi_printf("\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_scopes";
    d.calltf = scopes_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
