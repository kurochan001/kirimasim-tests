/* VPI application of test_vpi_ref_obj_actual_port_insts (IEEE 1800-2023 37.15). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_ref_obj_actual_port_insts"
#define MAX 8

/* vpi_get_str() returns every string in one buffer (38.11), so each string is
   copied into one of a few buffers, enough for the strings of one line. */
static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    static char copies[4][96];
    static int next;
    char *c = copies[next++ % 4];
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;

    snprintf(c, sizeof copies[0], "%s", s != NULL ? s : "NULL");
    return c;
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

static vpiHandle io_of(vpiHandle owner, const char *name)
{
    vpiHandle it = owner != NULL ? vpi_iterate(vpiIODecl, owner) : NULL, d;

    while (it != NULL && (d = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, d), name) == 0) {
            vpi_release_handle(it);
            return d;
        }
    return NULL;
}

static void one(const char *label, vpiHandle decl)
{
    vpiHandle ref = decl != NULL ? vpi_handle(vpiExpr, decl) : NULL;
    vpiHandle actual = ref != NULL ? vpi_handle(vpiActual, ref) : NULL;
    PLI_INT32 t = actual != NULL ? vpi_get(vpiType, actual) : 0;

    vpi_printf((PLI_BYTE8 *)"%s: ref obj %d", label,
               ref != NULL && vpi_get(vpiType, ref) == vpiRefObj);
    if (t == vpiInterface) {
        vpi_printf((PLI_BYTE8 *)", actual interface %s, def name %s",
                   sprop(vpiFullName, actual), sprop(vpiDefName, ref));
    } else if (t == vpiModport) {
        vpi_printf((PLI_BYTE8 *)", actual modport %s, def name %s",
                   sprop(vpiName, actual), sprop(vpiDefName, ref));
    } else if (actual != NULL) {
        vpi_printf((PLI_BYTE8 *)", actual variable %s value %d",
                   sprop(vpiFullName, actual), int_value(actual));
    } else {
        vpi_printf((PLI_BYTE8 *)", no actual");
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 refs_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle u = by_name("u"), bdecl = NULL, ref, it, port;
    char names[MAX][32];
    int n = 0, i, j;

    (void)user_data;
    if (u == NULL) {
        vpi_printf((PLI_BYTE8 *)"u: not found\n");
        return 0;
    }
    one("r", io_of(u, "r"));
    bdecl = io_of(u, "b");
    one("b", bdecl);
    one("d", io_of(u, "d"));

    ref = bdecl != NULL ? vpi_handle(vpiExpr, bdecl) : NULL;
    it = ref != NULL ? vpi_iterate(vpiPortInst, ref) : NULL;
    while (it != NULL && (port = vpi_scan(it)) != NULL && n < MAX) {
        vpiHandle parent = vpi_handle(vpiParent, port);
        snprintf(names[n++], sizeof names[0], "%s %s", sprop(vpiName, parent),
                 sprop(vpiName, port));
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (strcmp(names[i], names[j]) > 0) {
                char t[32];
                snprintf(t, sizeof t, "%s", names[i]);
                snprintf(names[i], sizeof names[i], "%s", names[j]);
                snprintf(names[j], sizeof names[j], "%s", t);
            }
    vpi_printf((PLI_BYTE8 *)"ports inst of b: %d\n", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", names[i]);
    return 0;
}

static PLI_INT32 taskref_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top != NULL ? vpi_iterate(vpiTask, top) : NULL, t = NULL, h;

    (void)user_data;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, h), "t") == 0)
            t = h;
    one("task t formal x", io_of(t, "x"));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_refs";
    d.calltf = refs_calltf;
    vpi_register_systf(&d);
    d.tfname = (PLI_BYTE8 *)"$vt_taskref";
    d.calltf = taskref_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
