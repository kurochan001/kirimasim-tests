/* VPI application of test_vpi_ansi_port_inheritance (IEEE 1800-2023 23.2.2.3). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Instance and port names, in the order in which they are printed. */
static const char *const names[][2] = {
    {"u1", "a"}, {"u1", "b"},
    {"u2", "x"}, {"u2", "y"}, {"u2", "z"},
    {"u3", "s"}, {"u3", "t"},
    {"u4", "p"}, {"u4", "q"}, {"u4", "r"}, {"u4", "g"}, {"u4", "h"},
    {"u4", "e"}, {"u4", "f"}, {"u4", "k"}, {"u4", "v"},
    {"u5", "a5"}, {"u5", "b5"},
};
#define COUNT ((int)(sizeof names / sizeof names[0]))

static const char *direction(vpiHandle port)
{
    switch (vpi_get(vpiDirection, port)) {
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other direction";
    }
}

/* The port of the instance with the given name, found by iterating vpiPort. */
static vpiHandle find_port(const char *inst, const char *port)
{
    char full[96];
    vpiHandle mod, it, p, found = NULL;

    snprintf(full, sizeof full, "test_vpi_ansi_port_inheritance.%s", inst);
    mod = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    it = mod ? vpi_iterate(vpiPort, mod) : NULL;
    while (it && (p = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *n = vpi_get_str(vpiName, p);
        if (found == NULL && n != NULL && strcmp(n, port) == 0)
            found = p;
    }
    return found;
}

static void describe(const char *inst, const char *port)
{
    char full[96];
    vpiHandle p = find_port(inst, port), obj;
    const char *kind;

    snprintf(full, sizeof full, "test_vpi_ansi_port_inheritance.%s.%s", inst, port);
    obj = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (p == NULL || obj == NULL) {
        vpi_printf("%s.%s: not found\n", inst, port);
        return;
    }
    switch (vpi_get(vpiType, obj)) {
    case vpiNet: kind = "logic net"; break;
    case vpiReg: kind = "logic variable"; break;
    case vpiIntegerVar: kind = "integer variable"; break;
    case vpiNetArray: kind = "net array"; break;
    default: kind = "other"; break;
    }
    if (vpi_get(vpiType, obj) == vpiNetArray)
        vpi_printf("%s.%s: %s %s of %d\n", inst, port, direction(p), kind,
                   (int)vpi_get(vpiSize, obj));
    else
        vpi_printf("%s.%s: %s %s%s, %d bits\n", inst, port, direction(p),
                   vpi_get(vpiSigned, obj) ? "signed " : "", kind, (int)vpi_get(vpiSize, obj));
}

static PLI_INT32 ports_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    for (i = 0; i < COUNT; i++)
        describe(names[i][0], names[i][1]);
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
