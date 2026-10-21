/* VPI application of test_vpi_drivers_loads_ports_force (IEEE 1800-2023
 * 37.46, 37.21). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_drivers_loads_ports_force"
#define MAX 16

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* What one driver or load is; a port connected to the net through an
 * expression also says what its high connection is. */
static void describe(vpiHandle h, char *out, size_t size, int with_conn)
{
    vpiHandle hc;
    switch (vpi_get(vpiType, h)) {
    case vpiPort:
        if (!with_conn) {
            snprintf(out, size, "port");
            break;
        }
        hc = vpi_handle(vpiHighConn, h);
        if (hc == NULL)
            snprintf(out, size, "port with no high connection");
        else if (vpi_get(vpiType, hc) == vpiOperation)
            snprintf(out, size, "port with high connection %s operation",
                     vpi_get(vpiOpType, hc) == vpiNotOp ? "not" : "other");
        else
            snprintf(out, size, "port with high connection %s",
                     vpi_get_str(vpiName, hc) ? vpi_get_str(vpiName, hc) : "(null)");
        break;
    case vpiForce: snprintf(out, size, "force"); break;
    case vpiAssignStmt: snprintf(out, size, "assign stmt"); break;
    case vpiContAssign: snprintf(out, size, "cont assign"); break;
    case vpiPrimTerm: snprintf(out, size, "prim term"); break;
    case vpiDelayTerm: snprintf(out, size, "delay term"); break;
    default: snprintf(out, size, "other"); break;
    }
}

/* The drivers or loads of a net or variable, a bit of a continuous
 * assignment or of a port standing for the assignment or port, each object
 * once, printed sorted. */
static void relation(const char *label, PLI_INT32 rel, const char *name, int with_conn)
{
    char full[96], text[MAX][64];
    vpiHandle seen[MAX], obj, it, h;
    int n = 0, i;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    obj = vpi_handle_by_name(full, NULL);
    if (obj == NULL) {
        vpi_printf("%s %s: not found\n", label, name);
        return;
    }
    it = vpi_iterate(rel, obj);
    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_INT32 t = vpi_get(vpiType, h);
        if (t == vpiContAssignBit || t == vpiPortBit)
            h = vpi_handle(vpiParent, h);
        if (h == NULL || n == MAX)
            continue;
        for (i = 0; i < n; i++)
            if (vpi_compare_objects(seen[i], h))
                break;
        if (i < n)
            continue;
        seen[n] = h;
        describe(h, text[n], sizeof text[n], with_conn);
        n++;
    }
    qsort(text, n, sizeof text[0], by_text);
    vpi_printf("%s %s:", label, name);
    for (i = 0; i < n; i++)
        vpi_printf("%s %s", i ? "," : "", text[i]);
    vpi_printf("\n");
}

static PLI_INT32 dl_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    relation("drivers of", vpiDriver, "n", 0);
    relation("loads of", vpiLoad, "n", 1);
    relation("loads of", vpiLoad, "m", 0);
    relation("loads of", vpiLoad, "w", 0);
    relation("drivers of", vpiDriver, "v", 0);
    relation("drivers of", vpiDriver, "f", 0);
    relation("loads of", vpiLoad, "g", 0);
    relation("drivers of", vpiDriver, "q", 0);
    relation("loads of", vpiLoad, "h", 0);
    relation("drivers of", vpiDriver, "ps", 0);
    relation("loads of", vpiLoad, "ps", 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_dl";
    d.calltf = dl_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
