/* VPI application of test_vpi_net_local_active_connectivity (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_local_active_connectivity"
#define MAX 12
#define LEN 48

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* Describes a driver or load; a bit of a continuous assignment or a port
   counts as its parent. */
static void describe(vpiHandle h, char *out)
{
    vpiHandle x;
    PLI_INT32 t = vpi_get(vpiType, h);

    if (t == vpiContAssignBit || t == vpiPortBit) {
        h = vpi_handle(vpiParent, h);
        t = h ? vpi_get(vpiType, h) : 0;
    }
    switch (t) {
    case vpiPort:
        snprintf(out, LEN, "port %s", vpi_get_str(vpiName, h));
        break;
    case vpiContAssign:
        x = vpi_handle(vpiLhs, h);
        snprintf(out, LEN, "cont assign to %s", x ? vpi_get_str(vpiName, x) : "?");
        break;
    case vpiPrimTerm:
        x = vpi_handle(vpiPrimitive, h);
        snprintf(out, LEN, "terminal %d of %s", (int)vpi_get(vpiTermIndex, h),
                 x ? vpi_get_str(vpiName, x) : "?");
        break;
    case vpiForce: snprintf(out, LEN, "force"); break;
    case vpiAssignStmt: snprintf(out, LEN, "assign stmt"); break;
    default: snprintf(out, LEN, "other object"); break;
    }
}

/* Collects the distinct descriptions of vpi_iterate(rel, obj), sorted. */
static int collect(PLI_INT32 rel, vpiHandle obj, char list[MAX][LEN])
{
    vpiHandle it = obj ? vpi_iterate(rel, obj) : NULL, h;
    char d[LEN];
    int n = 0, i;
    while (it && (h = vpi_scan(it)) != NULL) {
        describe(h, d);
        for (i = 0; i < n && strcmp(list[i], d) != 0; i++)
            ;
        if (i == n && n < MAX)
            strcpy(list[n++], d);
    }
    qsort(list, n, LEN, by_text);
    return n;
}

static void show(const char *label, PLI_INT32 rel, vpiHandle obj)
{
    char list[MAX][LEN];
    int n = collect(rel, obj, list), i;
    vpi_printf("%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf("%s %s", i ? "," : "", list[i]);
    if (n == 0)
        vpi_printf(" none");
    vpi_printf("\n");
}

static vpiHandle net(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name(full, NULL);
}

static PLI_INT32 local_calltf(PLI_BYTE8 *user_data)
{
    static const char *const names[] = {"a", "n", "y", "z"};
    char label[64];
    int i;

    (void)user_data;
    for (i = 0; i < 4; i++) {
        char path[16];
        snprintf(path, sizeof path, "u.%s", names[i]);
        snprintf(label, sizeof label, "local drivers of u.%s", names[i]);
        show(label, vpiLocalDriver, net(path));
        snprintf(label, sizeof label, "local loads of u.%s", names[i]);
        show(label, vpiLocalLoad, net(path));
    }
    return 0;
}

static PLI_INT32 active_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle args = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    char list[MAX][LEN];
    s_vpi_value v;
    int n, i, found = 0;

    (void)user_data;
    v.format = vpiStringVal;
    vpi_get_value(vpi_scan(args), &v);
    vpi_printf("%s\n", v.value.str);
    vpi_free_object(args);
    show("  drivers of ftgt", vpiDriver, net("ftgt"));
    show("  loads of fsrc", vpiLoad, net("fsrc"));
    n = collect(vpiDriver, net("tq"), list);
    for (i = 0; i < n; i++)
        if (strcmp(list[i], "port o") == 0)
            found = 1;
    vpi_printf("  port o among the drivers of tq: %d\n", found);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_local";
    d.calltf = local_calltf;
    vpi_register_systf(&d);
    d.tfname = (PLI_BYTE8 *)"$vt_active";
    d.calltf = active_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
