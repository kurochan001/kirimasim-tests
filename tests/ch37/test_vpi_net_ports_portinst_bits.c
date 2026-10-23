/* VPI application of test_vpi_net_ports_portinst_bits (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_ports_portinst_bits"

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static void show(const char *label, PLI_INT32 rel, vpiHandle obj)
{
    vpiHandle it = obj ? vpi_iterate(rel, obj) : NULL, h, p, inst;
    int n = 0;

    vpi_printf("%s:", label);
    while (it && (h = vpi_scan(it)) != NULL) {
        vpi_printf("%s ", n++ ? "," : "");
        if (vpi_get(vpiType, h) == vpiPort) {
            inst = vpi_handle(vpiInstance, h);
            vpi_printf("port %s of %s", copy(vpi_get_str(vpiName, h)),
                       inst ? copy(vpi_get_str(vpiName, inst)) : "NULL");
        } else if (vpi_get(vpiType, h) == vpiPortBit) {
            p = vpi_handle(vpiParent, h);
            vpi_printf("port bit of port %s", p ? copy(vpi_get_str(vpiName, p)) : "NULL");
        } else {
            vpi_printf("other object");
        }
    }
    if (n == 0)
        vpi_printf(" none");
    vpi_printf("\n");
}

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name(full, NULL);
}

static void conns(const char *name)
{
    vpiHandle u = by_name("u"), it = u ? vpi_iterate(vpiPort, u) : NULL, p, lo, hi;
    while (it && (p = vpi_scan(it)) != NULL) {
        if (strcmp(vpi_get_str(vpiName, p), name) != 0)
            continue;
        lo = vpi_handle(vpiLowConn, p);
        hi = vpi_handle(vpiHighConn, p);
        vpi_printf("port %s: low conn %s", name, lo ? copy(vpi_get_str(vpiFullName, lo)) : "NULL");
        vpi_printf(", high conn %s\n", hi ? copy(vpi_get_str(vpiFullName, hi)) : "NULL");
        vpi_free_object(it);
        return;
    }
    vpi_printf("port %s not found\n", name);
}

static PLI_INT32 ports_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle v = by_name("u.v"), tw = by_name("tw");

    (void)user_data;
    show("vpiPorts of u.v", vpiPorts, v);
    show("vpiPorts of u.v[1]", vpiPorts, v ? vpi_handle_by_index(v, 1) : NULL);
    show("vpiPorts of u.s", vpiPorts, by_name("u.s"));
    show("vpiPortInst of tw", vpiPortInst, tw);
    show("vpiPortInst of tw[0]", vpiPortInst, tw ? vpi_handle_by_index(tw, 0) : NULL);
    show("vpiPortInst of tw[3]", vpiPortInst, tw ? vpi_handle_by_index(tw, 3) : NULL);
    show("vpiPortInst of ts", vpiPortInst, by_name("ts"));
    show("vpiPortInst of tc", vpiPortInst, by_name("tc"));
    show("vpiPortInst of tc[0]", vpiPortInst,
         by_name("tc") ? vpi_handle_by_index(by_name("tc"), 0) : NULL);
    conns("v");
    conns("s");
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
