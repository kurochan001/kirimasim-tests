/* VPI application of test_vpi_routines_traverse_hierarchy (IEEE 1800-2023 36.11, Table 36-3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_routines_traverse_hierarchy"
#define MAX_NAMES 8

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* Iterates the relation, scans it to its end and prints the names sorted. */
static void list(const char *label, PLI_INT32 relation, vpiHandle ref)
{
    char names[MAX_NAMES][32];
    int n = 0, k;
    vpiHandle it = ref == NULL ? NULL : vpi_iterate(relation, ref), obj;

    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        const char *name = vpi_get_str(vpiName, obj);
        if (n < MAX_NAMES)
            snprintf(names[n], sizeof names[0], "%s", name ? name : "?");
        n++;
    }
    qsort(names, n < MAX_NAMES ? n : MAX_NAMES, sizeof names[0], by_text);
    vpi_printf("%s: %d objects:", label, n);
    for (k = 0; k < n && k < MAX_NAMES; k++)
        vpi_printf(" %s", names[k]);
    vpi_printf("\n");
}

static vpiHandle first_port(const char *instance)
{
    vpiHandle inst = vpi_handle_by_name((PLI_BYTE8 *)instance, NULL);
    vpiHandle it = inst == NULL ? NULL : vpi_iterate(vpiPort, inst), port = NULL, p;
    while (it != NULL && (p = vpi_scan(it)) != NULL)
        if (port == NULL)
            port = p;
    return port;
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle d1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".d1", NULL);
    vpiHandle inner = vpi_handle_by_name((PLI_BYTE8 *)TOP ".d1.inner", NULL);
    vpiHandle mod, out, in, path;
    const char *name;

    (void)data;
    list("vpi_iterate(vpiModule) of the top module, then vpi_scan", vpiModule, top);
    list("vpi_iterate(vpiNet) of d1, then vpi_scan", vpiNet, d1);
    mod = inner == NULL ? NULL : vpi_handle(vpiModule, inner);
    name = mod == NULL ? NULL : vpi_get_str(vpiFullName, mod);
    vpi_printf("vpi_handle(vpiModule) of d1.inner: %s\n", name ? name : "NULL");
    out = first_port(TOP ".s");
    in = first_port(TOP ".d1");
    path = out == NULL || in == NULL ? NULL : vpi_handle_multi(vpiInterModPath, out, in);
    vpi_printf("vpi_handle_multi(vpiInterModPath) of s.o and d1.i: type vpiInterModPath %d\n",
               path != NULL && vpi_get(vpiType, path) == vpiInterModPath);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
