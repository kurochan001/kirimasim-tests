/* VPI application of test_vpi_interface_modport_links (IEEE 1800-2023 37.6, 37.7, 37.8, 37.30). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interface_modport_links"
#define MAX 8

struct named {
    char name[48];
    vpiHandle h;
};

static const char *str_of(PLI_INT32 prop, vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    return s != NULL ? s : "none";
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct named *)a)->name, ((const struct named *)b)->name);
}

/* Collects the objects of an iteration with their vpiName, sorted by name. */
static int collect(PLI_INT32 type, vpiHandle ref, struct named *list)
{
    vpiHandle it = ref != NULL ? vpi_iterate(type, ref) : NULL, h;
    int n = 0;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        snprintf(list[n].name, sizeof list[n].name, "%s", str_of(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    return n;
}

/* Counts the objects of an iteration over b and those whose vpiInstance is b. */
static void instance_items(const char *label, PLI_INT32 type, vpiHandle b)
{
    vpiHandle it = vpi_iterate(type, b), h;
    int n = 0, in_b = 0;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        n++;
        in_b += same(vpi_handle(vpiInstance, h), b);
    }
    vpi_printf((PLI_BYTE8 *)"b: %s %d, their instance is b %d\n", label, n, in_b);
}

static void modports(vpiHandle b)
{
    struct named mp[MAX], io[MAX];
    int n = collect(vpiModport, b, mp), i, j, m, back;

    for (i = 0; i < n; i++) {
        vpi_printf((PLI_BYTE8 *)"modport %s: interface is b %d, instance is b %d", mp[i].name,
                   same(vpi_handle(vpiInterface, mp[i].h), b),
                   same(vpi_handle(vpiInstance, mp[i].h), b));
        if (strcmp(mp[i].name, "host") == 0) {
            m = collect(vpiIODecl, mp[i].h, io);
            back = 0;
            vpi_printf((PLI_BYTE8 *)", io declarations");
            for (j = 0; j < m; j++) {
                vpi_printf((PLI_BYTE8 *)" %s", io[j].name);
                back += same(vpi_handle(vpiModport, io[j].h), mp[i].h);
            }
            vpi_printf((PLI_BYTE8 *)", leading back to host %d", back);
        }
        vpi_printf((PLI_BYTE8 *)"\n");
    }
}

static void tf_decls(vpiHandle b)
{
    vpiHandle it = vpi_iterate(vpiInterfaceTfDecl, b), d, task;
    struct named io[MAX];
    int m, j;

    while (it != NULL && (d = vpi_scan(it)) != NULL) {
        task = vpi_handle(vpiTask, d);
        vpi_printf((PLI_BYTE8 *)"interface tf decl %s: extern %d, task %d, io declarations of "
                   "the task:", str_of(vpiName, task), vpi_get(vpiAccessType, d) == vpiExternAcc,
                   task != NULL && vpi_get(vpiType, task) == vpiTask);
        m = collect(vpiIODecl, task, io);
        for (j = 0; j < m; j++)
            vpi_printf((PLI_BYTE8 *)" %s %s", io[j].name,
                       vpi_get(vpiDirection, io[j].h) == vpiInput ? "input" : "other");
        vpi_printf((PLI_BYTE8 *)"\n");
    }
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void typedefs(vpiHandle top)
{
    struct named td[MAX];
    int n = collect(vpiTypedef, top, td), i;
    vpiHandle it, pa, rhs, el;

    for (i = 0; i < n; i++) {
        vpiHandle t = td[i].h;
        vpi_printf((PLI_BYTE8 *)"typedef %s:", td[i].name);
        if (vpi_get(vpiType, t) == vpiInterfaceTypespec) {
            struct named pas[MAX];
            int m = 0, j;
            vpi_printf((PLI_BYTE8 *)" interface typespec, definition %s", str_of(vpiDefName, t));
            it = vpi_iterate(vpiParamAssign, t);
            while (it != NULL && (pa = vpi_scan(it)) != NULL) {
                if (m == MAX)
                    continue;
                rhs = vpi_handle(vpiRhs, pa);
                if (rhs != NULL)
                    snprintf(pas[m].name, sizeof pas[m].name, "%s = %d",
                             str_of(vpiName, vpi_handle(vpiLhs, pa)), int_value(rhs));
                else
                    snprintf(pas[m].name, sizeof pas[m].name, "%s = none",
                             str_of(vpiName, vpi_handle(vpiLhs, pa)));
                pas[m++].h = pa;
            }
            /* The order of the parameter assignments is not fixed. */
            qsort(pas, m, sizeof pas[0], by_name);
            vpi_printf((PLI_BYTE8 *)", parameters:");
            for (j = 0; j < m; j++)
                vpi_printf((PLI_BYTE8 *)"%s %s", j ? "," : "", pas[j].name);
        } else if (vpi_get(vpiType, t) == vpiArrayTypespec) {
            el = vpi_handle(vpiElemTypespec, t);
            vpi_printf((PLI_BYTE8 *)" array typespec, element: interface typespec %d, "
                       "definition %s, modport %d",
                       el != NULL && vpi_get(vpiType, el) == vpiInterfaceTypespec,
                       str_of(vpiDefName, el), el ? (int)vpi_get(vpiIsModPort, el) : -1);
        } else {
            vpi_printf((PLI_BYTE8 *)" other typespec");
        }
        vpi_printf((PLI_BYTE8 *)"\n");
    }
}

static PLI_INT32 links_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle b = vpi_handle_by_name((PLI_BYTE8 *)TOP ".b", NULL);
    struct named nest[MAX];
    int n, i;

    (void)user_data;
    if (top == NULL || b == NULL) {
        vpi_printf((PLI_BYTE8 *)"instance not found\n");
        return 0;
    }
    n = collect(vpiInterface, b, nest);
    vpi_printf((PLI_BYTE8 *)"b: nested interfaces:");
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s of %s", nest[i].name, str_of(vpiDefName, nest[i].h));
    vpi_printf((PLI_BYTE8 *)"\nb: default clocking %s\n",
               str_of(vpiName, vpi_handle(vpiDefaultClocking, b)));
    instance_items("continuous assignments", vpiContAssign, b);
    instance_items("processes", vpiProcess, b);
    modports(b);
    tf_decls(b);
    typedefs(top);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_links";
    d.calltf = links_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
