/* VPI application of test_vpi_ports (IEEE 1800-2023 37.14). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 8

static const char *direction(vpiHandle port)
{
    switch (vpi_get(vpiDirection, port)) {
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other direction";
    }
}

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h ? vpi_get_str(vpiName, h) : NULL;
    return h == NULL ? "NULL" : s ? s : "(null)";
}

static PLI_INT32 ports_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle u = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_ports.u", NULL);
    vpiHandle it = u ? vpi_iterate(vpiPort, u) : NULL, p;
    vpiHandle ports[MAX];
    int n = 0, i;

    (void)user_data;
    memset(ports, 0, sizeof ports);
    while (it && (p = vpi_scan(it)) != NULL) {
        int index = (int)vpi_get(vpiPortIndex, p);
        n++;
        if (index >= 0 && index < MAX)
            ports[index] = p;
    }
    vpi_printf("ports: %d\n", n);
    for (i = 0; i < MAX; i++) {
        char name[32];
        p = ports[i];
        if (p == NULL)
            continue;
        snprintf(name, sizeof name, "%s", name_of(p));
        vpi_printf("port %d: %s, size %d", i, name, (int)vpi_get(vpiSize, p));
        if (vpi_get(vpiSize, p) > 0)
            vpi_printf(", %s, %s", direction(p),
                       vpi_get(vpiScalar, p) == 1   ? "scalar"
                       : vpi_get(vpiVector, p) == 1 ? "vector"
                                                    : "neither");
        snprintf(name, sizeof name, "%s", name_of(vpi_handle(vpiHighConn, p)));
        vpi_printf(", high conn %s", name);
        vpi_printf(", low conn %s\n", name_of(vpi_handle(vpiLowConn, p)));
    }
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
