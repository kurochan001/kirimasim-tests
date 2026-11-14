/* VPI application of test_vpi_ref_obj_declared_cases (IEEE 1800-2023 37.15). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define DEV "test_vpi_ref_obj_declared_cases.d"
#define MAX 8

/* vpi_get_str() returns every string in one buffer (38.11), so each string is
   copied before the next one is asked for. */
static void copy_str(char *out, size_t size, PLI_INT32 prop, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    snprintf(out, size, "%s", s != NULL ? s : "NULL");
}

static void print_actual(vpiHandle ro)
{
    vpiHandle a = vpi_handle(vpiActual, ro);
    char name[160];
    const char *kind;

    if (a == NULL) {
        vpi_printf((PLI_BYTE8 *)", actual NULL");
        return;
    }
    switch (vpi_get(vpiType, a)) {
    case vpiInterface: kind = "interface"; break;
    case vpiModport: kind = "modport"; break;
    case vpiNet: kind = "net"; break;
    case vpiLogicVar: kind = "logic var"; break;
    case vpiVarBit: kind = "var bit"; break;
    case vpiNamedEvent: kind = "named event"; break;
    case vpiNamedEventArray: kind = "named event array"; break;
    default: kind = "another kind of object"; break;
    }
    /* A modport has a name but no full name of its own. */
    copy_str(name, sizeof name, vpi_get(vpiType, a) == vpiModport ? vpiName : vpiFullName, a);
    vpi_printf((PLI_BYTE8 *)", actual %s %s", kind, name);
}

static void print_parent(vpiHandle ro)
{
    vpiHandle p = vpi_handle(vpiParent, ro);
    char name[64];

    if (p == NULL) {
        vpi_printf((PLI_BYTE8 *)", parent NULL");
    } else if (vpi_get(vpiType, p) != vpiRefObj) {
        vpi_printf((PLI_BYTE8 *)", parent not a ref obj");
    } else {
        copy_str(name, sizeof name, vpiName, p);
        vpi_printf((PLI_BYTE8 *)", parent ref obj %s", name);
    }
}

static PLI_INT32 ref_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle args = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle label = args != NULL ? vpi_scan(args) : NULL;
    vpiHandle use = label != NULL ? vpi_scan(args) : NULL;
    s_vpi_value v;
    char text[16];

    (void)user_data;
    if (use != NULL)
        vpi_free_object(args);
    if (label == NULL || use == NULL)
        return 0;
    v.format = vpiStringVal;
    vpi_get_value(label, &v);
    snprintf(text, sizeof text, "%s", v.value.str);
    vpi_printf((PLI_BYTE8 *)"use of %s: ", text);
    if (vpi_get(vpiType, use) != vpiRefObj) {
        vpi_printf((PLI_BYTE8 *)"not a ref obj\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"ref obj");
    print_actual(use);
    if (strcmp(text, "r[1]") == 0 || strcmp(text, "ea[1]") == 0 || strcmp(text, "f[2]") == 0)
        print_parent(use);
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static PLI_INT32 ports_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle d = vpi_handle_by_name((PLI_BYTE8 *)DEV, NULL);
    vpiHandle it = d != NULL ? vpi_iterate(vpiPort, d) : NULL, p, lc, ports[MAX];
    char pname[32], lname[32];
    int i;

    (void)user_data;
    memset(ports, 0, sizeof ports);
    while (it != NULL && (p = vpi_scan(it)) != NULL) {
        int index = (int)vpi_get(vpiPortIndex, p);
        if (index >= 0 && index < MAX)
            ports[index] = p;
    }
    for (i = 0; i < MAX; i++) {
        if (ports[i] == NULL)
            continue;
        copy_str(pname, sizeof pname, vpiName, ports[i]);
        vpi_printf((PLI_BYTE8 *)"port %s: low conn ", pname);
        lc = vpi_handle(vpiLowConn, ports[i]);
        if (lc == NULL || vpi_get(vpiType, lc) != vpiRefObj) {
            vpi_printf((PLI_BYTE8 *)"not a ref obj\n");
            continue;
        }
        copy_str(lname, sizeof lname, vpiName, lc);
        vpi_printf((PLI_BYTE8 *)"ref obj %s", lname);
        print_actual(lc);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_ref", ref_calltf);
    add("$vt_ports", ports_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
