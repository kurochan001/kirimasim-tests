/* VPI application of test_vpi_io_decl_scope_typespec_ports (37.13, 37.14). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_io_decl_scope_typespec_ports"
#define MAX 12

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "NULL";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1000;
    v.format = vpiIntVal;
    v.value.integer = -1000;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static vpiHandle by_name(const char *path)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, path);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* Prints the number of ranges and each range, e.g. "1 7:0" or "0". */
static void ranges(const char *prefix, vpiHandle h)
{
    vpiHandle it = h != NULL ? vpi_iterate(vpiRange, h) : NULL, r;
    int n = 0;

    while (it != NULL && (r = vpi_scan(it)) != NULL)
        n++;
    vpi_printf((PLI_BYTE8 *)"%s %d", prefix, n);
    it = h != NULL ? vpi_iterate(vpiRange, h) : NULL;
    while (it != NULL && (r = vpi_scan(it)) != NULL)
        vpi_printf((PLI_BYTE8 *)" %d:%d", int_value(vpi_handle(vpiLeftRange, r)),
                   int_value(vpi_handle(vpiRightRange, r)));
}

static int same_ranges(vpiHandle a, vpiHandle b)
{
    vpiHandle ia = a != NULL ? vpi_iterate(vpiRange, a) : NULL;
    vpiHandle ib = b != NULL ? vpi_iterate(vpiRange, b) : NULL, ra, rb;
    for (;;) {
        ra = ia != NULL ? vpi_scan(ia) : NULL;
        rb = ib != NULL ? vpi_scan(ib) : NULL;
        if (ra == NULL || rb == NULL)
            return ra == NULL && rb == NULL;
        if (int_value(vpi_handle(vpiLeftRange, ra)) != int_value(vpi_handle(vpiLeftRange, rb))
            || int_value(vpi_handle(vpiRightRange, ra)) != int_value(vpi_handle(vpiRightRange, rb)))
            return 0;
    }
}

/* Whether the io declaration of a task, function or UDP leads back to owner. */
static void owner(const char *label, vpiHandle decl, PLI_INT32 relation, vpiHandle want)
{
    vpiHandle back = decl != NULL ? vpi_handle(relation, decl) : NULL;
    vpi_printf((PLI_BYTE8 *)"%s%s: back with %s %d\n", label, sprop(vpiName, decl),
               relation == vpiTaskFunc ? "vpiTaskFunc" : "vpiUdpDefn",
               back != NULL && want != NULL && vpi_compare_objects(back, want));
}

/* Sorts decls[0] to decls[n - 1] by name. vpi_get_str() returns every string
   in one buffer (38.11), so the names are copied before they are compared. */
static void sort_by_name(vpiHandle *decls, int n)
{
    char names[MAX][24], t[24];
    vpiHandle th;
    int i, j;

    for (i = 0; i < n; i++)
        snprintf(names[i], sizeof names[0], "%s", sprop(vpiName, decls[i]));
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (strcmp(names[i], names[j]) > 0) {
                snprintf(t, sizeof t, "%s", names[i]);
                snprintf(names[i], sizeof names[i], "%s", names[j]);
                snprintf(names[j], sizeof names[j], "%s", t);
                th = decls[i];
                decls[i] = decls[j];
                decls[j] = th;
            }
}

static void io_decl(vpiHandle d, vpiHandle u)
{
    const char *name = sprop(vpiName, d);
    vpiHandle inst = vpi_handle(vpiInstance, d);
    vpiHandle spec = vpi_handle(vpiTypespec, d);
    vpiHandle expr = vpi_handle(vpiExpr, d);

    vpi_printf((PLI_BYTE8 *)"%s: instance is u %d", name,
               inst != NULL && u != NULL && vpi_compare_objects(inst, u));
    if (strcmp(name, "din") == 0 || strcmp(name, "dout") == 0
        || strcmp(name, "scalar") == 0 || strcmp(name, "vec") == 0) {
        vpi_printf((PLI_BYTE8 *)", direction %s, size %d, scalar %d, signed %d, vector %d",
                   vpi_get(vpiDirection, d) == vpiInput ? "input" :
                   vpi_get(vpiDirection, d) == vpiOutput ? "output" : "other",
                   (int)vpi_get(vpiSize, d), (int)vpi_get(vpiScalar, d),
                   (int)vpi_get(vpiSigned, d), (int)vpi_get(vpiVector, d));
        ranges(", ranges", d);
        vpi_printf((PLI_BYTE8 *)", typespec exists %d", spec != NULL);
        ranges(", typespec ranges", spec);
        vpi_printf((PLI_BYTE8 *)", same bounds %d", same_ranges(d, spec));
        if (vpi_handle(vpiLeftRange, d) != NULL)
            vpi_printf((PLI_BYTE8 *)", left/right io %d:%d typespec %d:%d same %d",
                       int_value(vpi_handle(vpiLeftRange, d)),
                       int_value(vpi_handle(vpiRightRange, d)),
                       int_value(vpi_handle(vpiLeftRange, spec)),
                       int_value(vpi_handle(vpiRightRange, spec)),
                       int_value(vpi_handle(vpiLeftRange, d))
                       == int_value(vpi_handle(vpiLeftRange, spec))
                       && int_value(vpi_handle(vpiRightRange, d))
                       == int_value(vpi_handle(vpiRightRange, spec)));
    } else if (strcmp(name, "rp") == 0) {
        vpi_printf((PLI_BYTE8 *)", ref %d, expr ref obj %d",
                   vpi_get(vpiDirection, d) == vpiRef,
                   expr != NULL && vpi_get(vpiType, expr) == vpiRefObj);
    } else if (strcmp(name, "vif") == 0) {
        vpi_printf((PLI_BYTE8 *)", expr virtual interface var %d",
                   expr != NULL && vpi_get(vpiType, expr) == vpiVirtualInterfaceVar);
    } else {
        vpi_printf((PLI_BYTE8 *)", expr ref obj %d",
                   expr != NULL && vpi_get(vpiType, expr) == vpiRefObj);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 io_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle u = by_name("u"), it, d, task = NULL, func = NULL, defn, udp;
    char names[MAX][24];
    vpiHandle decls[MAX];
    int n = 0, i, j;

    (void)user_data;
    if (u == NULL) {
        vpi_printf((PLI_BYTE8 *)"u: not found\n");
        return 0;
    }
    it = vpi_iterate(vpiIODecl, u);
    while (it != NULL && (d = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(names[n], sizeof names[0], "%s", sprop(vpiName, d));
        decls[n++] = d;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (strcmp(names[i], names[j]) > 0) {
                char t[24];
                vpiHandle th;
                snprintf(t, sizeof t, "%s", names[i]);
                snprintf(names[i], sizeof names[i], "%s", names[j]);
                snprintf(names[j], sizeof names[j], "%s", t);
                th = decls[i];
                decls[i] = decls[j];
                decls[j] = th;
            }
    for (i = 0; i < n; i++)
        io_decl(decls[i], u);

    it = vpi_iterate(vpiTask, u);
    while (it != NULL && (d = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, d), "t") == 0)
            task = d;
    it = vpi_iterate(vpiFunction, u);
    while (it != NULL && (d = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, d), "f") == 0)
            func = d;
    vpi_printf((PLI_BYTE8 *)"task t io declarations:\n");
    it = task != NULL ? vpi_iterate(vpiIODecl, task) : NULL;
    n = 0;
    while (it != NULL && (d = vpi_scan(it)) != NULL && n < MAX)
        decls[n++] = d;
    sort_by_name(decls, n);
    for (i = 0; i < n; i++)
        owner("  ", decls[i], vpiTaskFunc, task);
    for (i = 0; i < n; i++)
        if (strcmp(sprop(vpiName, decls[i]), "tr") == 0) {
            vpiHandle x = vpi_handle(vpiExpr, decls[i]);
            vpi_printf((PLI_BYTE8 *)"  tr: direction ref %d, expr ref obj %d\n",
                       vpi_get(vpiDirection, decls[i]) == vpiRef,
                       x != NULL && vpi_get(vpiType, x) == vpiRefObj);
        }
    vpi_printf((PLI_BYTE8 *)"function f io declarations:\n");
    it = func != NULL ? vpi_iterate(vpiIODecl, func) : NULL;
    while (it != NULL && (d = vpi_scan(it)) != NULL)
        owner("  ", d, vpiTaskFunc, func);

    udp = by_name("up");
    defn = udp != NULL ? vpi_handle(vpiUdpDefn, udp) : NULL;
    vpi_printf((PLI_BYTE8 *)"udp io declarations:\n");
    it = defn != NULL ? vpi_iterate(vpiIODecl, defn) : NULL;
    n = 0;
    while (it != NULL && (d = vpi_scan(it)) != NULL && n < MAX)
        decls[n++] = d;
    sort_by_name(decls, n);
    for (i = 0; i < n; i++)
        owner("  ", decls[i], vpiUdpDefn, defn);

    vpi_printf((PLI_BYTE8 *)"ports of u:\n");
    it = vpi_iterate(vpiPort, u);
    n = 0;
    while (it != NULL && (d = vpi_scan(it)) != NULL && n < MAX)
        decls[n++] = d;
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (vpi_get(vpiPortIndex, decls[i]) > vpi_get(vpiPortIndex, decls[j])) {
                vpiHandle th = decls[i];
                decls[i] = decls[j];
                decls[j] = th;
            }
    d = NULL;
    for (i = 0; i < n; i++) {
        vpiHandle p = decls[i];
        PLI_INT32 t = vpi_get(vpiPortType, p);
        if (strcmp(sprop(vpiName, p), "vif") == 0)
            vpi_printf((PLI_BYTE8 *)"  vif: index %d\n", (int)vpi_get(vpiPortIndex, p));
        else
            vpi_printf((PLI_BYTE8 *)"  %s: port %d, interface port %d, modport port %d, index %d\n",
                       sprop(vpiName, p), t == vpiPort, t == vpiInterfacePort,
                       t == vpiModportPort, (int)vpi_get(vpiPortIndex, p));
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_io";
    d.calltf = io_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
