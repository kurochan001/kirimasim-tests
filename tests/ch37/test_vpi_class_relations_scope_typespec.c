/* VPI application of test_vpi_class_relations_scope_typespec (37.31, 37.32). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_class_relations_scope_typespec"
#define MAX 12

static char names[MAX][64];
static vpiHandle handles[MAX];

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "NULL";
}

static vpiHandle top(void)
{
    return vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
}

static vpiHandle find_class(const char *name)
{
    vpiHandle it = vpi_iterate(vpiClassDefn, NULL), h;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, h), name) == 0) {
            vpi_release_handle(it);
            return h;
        }
    return NULL;
}

/* Collects a relation, sorted by name, and prints "  label: a b". */
static int collect(PLI_INT32 relation, vpiHandle owner, const char *label, int sorted)
{
    vpiHandle it = owner != NULL ? vpi_iterate(relation, owner) : NULL, h;
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(names[n], sizeof names[0], "%s", sprop(vpiName, h));
        handles[n++] = h;
    }
    if (sorted) {
        for (i = 0; i < n; i++) {
            int j;
            for (j = i + 1; j < n; j++)
                if (strcmp(names[i], names[j]) > 0) {
                    char t[64];
                    vpiHandle th = handles[i];
                    snprintf(t, sizeof t, "%s", names[i]);
                    snprintf(names[i], sizeof names[i], "%s", names[j]);
                    snprintf(names[j], sizeof names[j], "%s", t);
                    handles[i] = handles[j];
                    handles[j] = th;
                }
        }
    }
    vpi_printf((PLI_BYTE8 *)"  %s:", label);
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none");
    else {
        vpi_printf((PLI_BYTE8 *)" ");
        for (i = 0; i < n; i++)
            vpi_printf((PLI_BYTE8 *)"%s%s", i ? "," : "", names[i]);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
    return n;
}

static void back(PLI_INT32 relation, vpiHandle owner, const char *label, int sorted)
{
    int n = collect(relation, owner, label, sorted), i;

    for (i = 0; i < n; i++) {
        vpiHandle b = vpi_handle(vpiClassDefn, handles[i]);
        vpi_printf((PLI_BYTE8 *)"    %s: back to class definition %d\n", names[i],
                   b != NULL && vpi_compare_objects(b, owner));
    }
}

static void parameters(vpiHandle cls)
{
    vpiHandle it = cls != NULL ? vpi_iterate(vpiParameter, cls) : NULL, h;
    int n = 0, i, j;

    while (it != NULL && (h = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(names[n], sizeof names[0], "%s(local %d)", sprop(vpiName, h),
                 (int)vpi_get(vpiLocalParam, h));
        handles[n++] = h;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (strcmp(names[i], names[j]) > 0) {
                char t[64];
                vpiHandle th = handles[i];
                snprintf(t, sizeof t, "%s", names[i]);
                snprintf(names[i], sizeof names[i], "%s", names[j]);
                snprintf(names[j], sizeof names[j], "%s", t);
                handles[i] = handles[j];
                handles[j] = th;
            }
    vpi_printf((PLI_BYTE8 *)"  parameters:");
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none");
    else {
        vpi_printf((PLI_BYTE8 *)" ");
        for (i = 0; i < n; i++)
            vpi_printf((PLI_BYTE8 *)"%s%s", i ? "," : "", names[i]);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
    for (i = 0; i < n; i++) {
        vpiHandle b = vpi_handle(vpiClassDefn, handles[i]);
        vpi_printf((PLI_BYTE8 *)"    %s: back to class definition %d\n", names[i],
                   b != NULL && vpi_compare_objects(b, cls));
    }
}

static void class_info(vpiHandle cls)
{
    vpiHandle inst = vpi_handle(vpiInstance, cls);
    vpiHandle t = top();

    vpi_printf((PLI_BYTE8 *)"%s: instance is top %d, automatic %d\n",
               sprop(vpiName, cls),
               inst != NULL && t != NULL && vpi_compare_objects(inst, t),
               (int)vpi_get(vpiAutomatic, cls));
    back(vpiVariables, cls, "variables", 1);
    back(vpiMethods, cls, "methods", 1);
    back(vpiNamedEvent, cls, "named events", 1);
    back(vpiNamedEventArray, cls, "named event arrays", 1);
    back(vpiConstraint, cls, "constraints in order", 0);
    parameters(cls);
}

static PLI_INT32 classes_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it, h, cls, der, ext, base_ts, proc, spec;
    int n = 0, i, j;

    (void)user_data;
    it = vpi_iterate(vpiClassDefn, NULL);
    while (it != NULL && (h = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(names[n], sizeof names[0], "%s", sprop(vpiName, h));
        handles[n++] = h;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (strcmp(names[i], names[j]) > 0) {
                char t[64];
                vpiHandle th = handles[i];
                snprintf(t, sizeof t, "%s", names[i]);
                snprintf(names[i], sizeof names[i], "%s", names[j]);
                snprintf(names[j], sizeof names[j], "%s", t);
                handles[i] = handles[j];
                handles[j] = th;
            }
    vpi_printf((PLI_BYTE8 *)"classes from NULL root:");
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none");
    else {
        vpi_printf((PLI_BYTE8 *)" ");
        for (i = 0; i < n; i++)
            vpi_printf((PLI_BYTE8 *)"%s%s", i ? "," : "", names[i]);
    }
    vpi_printf((PLI_BYTE8 *)"\n");

    class_info(find_class("cr_base"));

    der = find_class("cr_der");
    class_info(der);
    vpi_printf((PLI_BYTE8 *)"cr_der typedefs:\n");
    {
        char tn[MAX][64];
        vpiHandle th[MAX];
        int nt = 0;
        it = der != NULL ? vpi_iterate(vpiTypedef, der) : NULL;
        while (it != NULL && (h = vpi_scan(it)) != NULL && nt < MAX) {
            snprintf(tn[nt], sizeof tn[0], "%s", sprop(vpiName, h));
            th[nt++] = h;
        }
        for (i = 0; i < nt; i++)
            for (j = i + 1; j < nt; j++)
                if (strcmp(tn[i], tn[j]) > 0) {
                    char t[64];
                    vpiHandle x = th[i];
                    snprintf(t, sizeof t, "%s", tn[i]);
                    snprintf(tn[i], sizeof tn[i], "%s", tn[j]);
                    snprintf(tn[j], sizeof tn[j], "%s", t);
                    th[i] = th[j];
                    th[j] = x;
                }
        for (i = 0; i < nt; i++)
            vpi_printf((PLI_BYTE8 *)"  %s: back to cr_der %d\n", tn[i],
                       vpi_handle(vpiClassDefn, th[i]) != NULL
                       && vpi_compare_objects(vpi_handle(vpiClassDefn, th[i]), der));
    }
    ext = der != NULL ? vpi_handle(vpiExtends, der) : NULL;
    base_ts = ext != NULL ? vpi_handle(vpiClassTypespec, ext) : NULL;
    vpi_printf((PLI_BYTE8 *)"cr_der extends %s\n",
               base_ts != NULL ? sprop(vpiName, vpi_handle(vpiClassDefn, base_ts)) : "none");
    if (ext != NULL) {
        vpiHandle a;
        int na = 0;
        it = vpi_iterate(vpiArgument, ext);
        vpi_printf((PLI_BYTE8 *)"  constructor chaining arguments:");
        while (it != NULL && (a = vpi_scan(it)) != NULL && na < MAX) {
            vpi_printf((PLI_BYTE8 *)"%s %s", na ? "," : "", sprop(vpiName, a));
            na++;
        }
        vpi_printf((PLI_BYTE8 *)"%s\n", na ? "" : " none");
    }
    if (base_ts != NULL) {
        vpi_printf((PLI_BYTE8 *)"cr_der base class definition %s\n",
                   vpi_handle(vpiClassDefn, base_ts) != NULL
                   && vpi_compare_objects(vpi_handle(vpiClassDefn, base_ts),
                                         find_class("cr_base")));
    }

    cls = find_class("cr_plain");
    {
        vpiHandle mit = cls != NULL ? vpi_iterate(vpiMethods, cls) : NULL, m;
        int nm = 0;
        while (mit != NULL && (m = vpi_scan(mit)) != NULL)
            nm++;
        vpi_printf((PLI_BYTE8 *)"cr_plain: methods %d\n", nm);
    }

    proc = vpi_handle_by_name((PLI_BYTE8 *)TOP ".proc", NULL);
    spec = proc != NULL ? vpi_handle(vpiTypespec, proc) : NULL;
    vpi_printf((PLI_BYTE8 *)"built-in process: classDefn NULL %d\n",
               vpi_handle(vpiClassDefn, spec) == NULL);
    (void)cls;
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
