/* VPI application of test_vpi_variable_port_relations (IEEE 1800-2023 37.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_port_relations"
#define MAX 8

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(*(char *const *)a, *(char *const *)b);
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

/* A port as instance.port[index]. */
static char *port_name(vpiHandle p)
{
    vpiHandle m = vpi_handle(vpiModule, p);
    char buf[128];
    snprintf(buf, sizeof buf, "%s.%s[%d]", m ? copy(vpi_get_str(vpiName, m)) : "NULL",
             copy(vpi_get_str(vpiName, p)), (int)vpi_get(vpiPortIndex, p));
    return copy(buf);
}

static void ports(const char *label, PLI_INT32 rel, vpiHandle var)
{
    vpiHandle it = var ? vpi_iterate(rel, var) : NULL, p;
    char *names[MAX];
    int n = 0, i;

    while (it != NULL && (p = vpi_scan(it)) != NULL)
        if (n < MAX)
            names[n++] = port_name(p);
    qsort(names, n, sizeof names[0], by_name);
    vpi_printf("%s of %s (%d):", rel == vpiPorts ? "vpiPorts" : "vpiPortInst", label, n);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    vpi_printf("\n");
}

static vpiHandle port_of(vpiHandle inst, const char *name)
{
    vpiHandle it = vpi_iterate(vpiPort, inst), p, found = NULL;
    while (it != NULL && (p = vpi_scan(it)) != NULL)
        if (found == NULL && strcmp(vpi_get_str(vpiName, p), name) == 0)
            found = p;
    return found;
}

static const char *var_kind(vpiHandle h)
{
    if (h == NULL)
        return "NULL";
    switch (vpi_get(vpiType, h)) {
    case vpiLogicVar: return "logic var";
    case vpiIntVar: return "int var";
    default: return "other type";
    }
}

static void conns(const char *label, vpiHandle port, const char *low, const char *high)
{
    vpiHandle l = port ? vpi_handle(vpiLowConn, port) : NULL;
    vpiHandle h = port ? vpi_handle(vpiHighConn, port) : NULL;
    vpi_printf("port %s: low connection %s, is %s %d; high connection %s", label, var_kind(l),
               low, same(l, find(low)), var_kind(h));
    if (high != NULL)
        vpi_printf(", is %s %d", high, same(h, find(high)));
    vpi_printf("\n");
}

static PLI_INT32 ports_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle u1 = find("u1"), u2 = find("u2");

    (void)user_data;
    if (u1 == NULL || u2 == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    ports("u1.y", vpiPorts, find("u1.y"));
    ports("u1.a", vpiPorts, find("u1.a"));
    ports("dst", vpiPorts, find("dst"));
    ports("src", vpiPortInst, find("src"));
    ports("dst", vpiPortInst, find("dst"));
    ports("u1.y", vpiPortInst, find("u1.y"));
    conns("u1.y", port_of(u1, "y"), "u1.y", "dst");
    conns("u1.n", port_of(u1, "n"), "u1.n", "cnt");
    conns("u2.y", port_of(u2, "y"), "u2.y", NULL);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ports";
    d.calltf = ports_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
