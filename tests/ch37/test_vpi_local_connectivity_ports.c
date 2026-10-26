/* VPI application of test_vpi_local_connectivity_ports (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_local_connectivity_ports"
#define MAX 8

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static vpiHandle net(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.u.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int by_text(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}

static void set(const char *label, PLI_INT32 relation, const char *name)
{
    vpiHandle h = net(name), it, o;
    const char *names[MAX];
    char storage[MAX][64];
    int n = 0, i, j;

    it = h != NULL ? vpi_iterate(relation, h) : NULL;
    while (it != NULL && (o = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(storage[n], sizeof storage[0], "%s (%s)", sprop(vpiName, o),
                 sprop(vpiType, o));
        names[n] = storage[n];
        n++;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (by_text(&names[i], &names[j]) > 0) {
                const char *t = names[i];
                names[i] = names[j];
                names[j] = t;
            }
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s%s", i ? ", " : " ", names[i]);
    vpi_printf((PLI_BYTE8 *)"%s\n", n ? "" : " none");
}

static PLI_INT32 local_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    set("local drivers of i", vpiLocalDriver, "i");
    set("local loads of o", vpiLocalLoad, "o");
    set("local drivers of io", vpiLocalDriver, "io");
    set("local loads of io", vpiLocalLoad, "io");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_local";
    d.calltf = local_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
