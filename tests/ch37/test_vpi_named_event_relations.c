/* VPI application of test_vpi_named_event_relations (IEEE 1800-2023 37.27). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_named_event_relations"
#define MAX 8

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "NULL";
}

static vpiHandle by_name(const char *path)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, path);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b);
}

static int is_boolean(PLI_INT32 property, vpiHandle h)
{
    PLI_INT32 v = vpi_get(property, h);
    return v == 0 || v == 1;
}

static void event(const char *label, vpiHandle e, vpiHandle owner)
{
    vpiHandle inst = vpi_handle(vpiInstance, e);
    vpiHandle scope = vpi_handle(vpiScope, e);
    vpiHandle module = vpi_handle(vpiModule, e);

    vpi_printf((PLI_BYTE8 *)"%s: full name %s, instance owner %d, scope owner %d, "
               "scope name %s, module owner %d, vpiArray bool %d\n",
               label, sprop(vpiFullName, e), same(inst, owner), same(scope, owner),
               sprop(vpiFullName, scope), same(module, owner), is_boolean(vpiArray, e));
}

static void event_array(const char *label, vpiHandle a, vpiHandle u)
{
    vpiHandle inst = vpi_handle(vpiInstance, a);
    vpiHandle module = vpi_handle(vpiModule, a);
    vpiHandle it, e;
    char names[MAX][96];
    int n = 0, i, j, all_events = 1;

    it = vpi_iterate(vpiNamedEvent, a);
    while (it != NULL && (e = vpi_scan(it)) != NULL && n < MAX) {
        if (vpi_get(vpiType, e) != vpiNamedEvent)
            all_events = 0;
        snprintf(names[n++], sizeof names[0], "%s", sprop(vpiFullName, e));
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (strcmp(names[i], names[j]) > 0) {
                char t[96];
                snprintf(t, sizeof t, "%s", names[i]);
                snprintf(names[i], sizeof names[i], "%s", names[j]);
                snprintf(names[j], sizeof names[j], "%s", t);
            }
    vpi_printf((PLI_BYTE8 *)"%s: full name %s, instance is u %d, module is u %d, "
               "elements %d, all vpiNamedEvent %d\n",
               label, sprop(vpiFullName, a), same(inst, u), same(module, u),
               n, all_events);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"  element %s\n", names[i]);
}

static PLI_INT32 events_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), u = by_name("u");

    (void)user_data;
    if (top == NULL || u == NULL) {
        vpi_printf((PLI_BYTE8 *)"scope not found\n");
        return 0;
    }
    event("ev", by_name("ev"), top);
    event("u.e1", by_name("u.e1"), u);
    event("u.e2", by_name("u.e2"), u);
    event_array("u.ea", by_name("u.ea"), u);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_events";
    d.calltf = events_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
