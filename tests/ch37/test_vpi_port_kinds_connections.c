/* VPI application of test_vpi_port_kinds_connections (IEEE 1800-2023 37.14, 37.15). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_port_kinds_connections"
#define MAX 8

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static const char *port_type(vpiHandle p)
{
    switch (vpi_get(vpiPortType, p)) {
    case vpiPort: return "vpiPort";
    case vpiInterfacePort: return "vpiInterfacePort";
    case vpiModportPort: return "vpiModportPort";
    default: return "other port type";
    }
}

static void show_conn(const char *side, vpiHandle c)
{
    vpiHandle actual;
    if (c == NULL) {
        vpi_printf(", %s NULL", side);
        return;
    }
    if (vpi_get(vpiType, c) != vpiRefObj) {
        vpi_printf(", %s %s", side, copy(vpi_get_str(vpiName, c)));
        return;
    }
    vpi_printf(", %s ref obj", side);
    actual = vpi_handle(vpiActual, c);
    if (actual == NULL)
        return;
    switch (vpi_get(vpiType, actual)) {
    case vpiInterface:
        vpi_printf(" of interface %s", copy(vpi_get_str(vpiFullName, actual)));
        break;
    case vpiModport:
        vpi_printf(" of modport %s", copy(vpi_get_str(vpiName, actual)));
        break;
    default: vpi_printf(" of another object"); break;
    }
}

static void show_bits(vpiHandle p)
{
    vpiHandle it = vpi_iterate(vpiBit, p), b;
    int n = 0, port_bits = 1, parents = 1;
    while (it && (b = vpi_scan(it)) != NULL) {
        vpiHandle parent = vpi_handle(vpiParent, b);
        n++;
        if (vpi_get(vpiType, b) != vpiPortBit)
            port_bits = 0;
        if (parent == NULL || !vpi_compare_objects(parent, p))
            parents = 0;
    }
    vpi_printf("  bits of %s: %d, all port bits %d, all with the port as parent %d\n",
               copy(vpi_get_str(vpiName, p)), n, n > 0 && port_bits, n > 0 && parents);
}

static void show_instance(const char *local, int with_typespec)
{
    char full[96];
    vpiHandle inst, it, p, ports[MAX], ts, h;
    int i;

    snprintf(full, sizeof full, "%s.%s", TOP, local);
    inst = vpi_handle_by_name(full, NULL);
    memset(ports, 0, sizeof ports);
    it = inst ? vpi_iterate(vpiPort, inst) : NULL;
    while (it && (p = vpi_scan(it)) != NULL) {
        int index = (int)vpi_get(vpiPortIndex, p);
        if (index >= 0 && index < MAX)
            ports[index] = p;
    }
    for (i = 0; i < MAX; i++) {
        p = ports[i];
        if (p == NULL)
            continue;
        vpi_printf("%s port %d %s: %s, conn by name %d, explicit name %d", local, i,
                   copy(vpi_get_str(vpiName, p)), port_type(p), (int)vpi_get(vpiConnByName, p),
                   (int)vpi_get(vpiExplicitName, p));
        if (vpi_get(vpiPortType, p) == vpiPort)
            vpi_printf(", size %d, scalar %d, vector %d", (int)vpi_get(vpiSize, p),
                       (int)vpi_get(vpiScalar, p), (int)vpi_get(vpiVector, p));
        show_conn("high conn", vpi_handle(vpiHighConn, p));
        if (vpi_get(vpiPortType, p) != vpiModportPort)
            show_conn("low conn", vpi_handle(vpiLowConn, p));
        h = vpi_handle(vpiInstance, p);
        vpi_printf(", instance %s", h ? copy(vpi_get_str(vpiFullName, h)) : "NULL");
        h = vpi_handle(vpiModule, p);
        vpi_printf(", module %s", h ? copy(vpi_get_str(vpiFullName, h)) : "NULL");
        if (with_typespec && vpi_get(vpiPortType, p) == vpiPort) {
            ts = vpi_handle(vpiTypespec, p);
            vpi_printf(", logic typespec %d", ts != NULL && vpi_get(vpiType, ts) == vpiLogicTypespec);
        }
        vpi_printf("\n");
        if (vpi_get(vpiPortType, p) == vpiPort && vpi_get(vpiSize, p) > 1)
            show_bits(p);
    }
}

static PLI_INT32 ports_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show_instance("ua", 1);
    show_instance("un", 0);
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
