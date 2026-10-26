/* VPI application of test_vpi_interconnect_net_typespec (IEEE 1800-2023 37.24). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interconnect_net_typespec"

static vpiHandle find(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* The typespec of the net that is the low connection of port o of inst. */
static vpiHandle port_net_typespec(const char *inst)
{
    vpiHandle m = find(inst);
    vpiHandle it = m != NULL ? vpi_iterate(vpiPorts, m) : NULL, p;

    while (it != NULL && (p = vpi_scan(it)) != NULL) {
        const char *name = vpi_get_str(vpiName, p);
        if (name != NULL && strcmp(name, "o") == 0) {
            vpiHandle low = vpi_handle(vpiLowConn, p);
            return low != NULL ? vpi_handle(vpiTypespec, low) : NULL;
        }
    }
    return NULL;
}

static int by_int(const void *a, const void *b)
{
    int x = *(const int *)a, y = *(const int *)b;
    return (x > y) - (x < y);
}

/* Prints the sizes of the objects that the relation iterates. */
static void sizes(const char *name, PLI_INT32 relation, const char *inst)
{
    vpiHandle obj = find(name);
    vpiHandle it = obj != NULL ? vpi_iterate(relation, obj) : NULL, h;
    int values[8], n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL && n < 8)
        values[n++] = (int)vpi_get(vpiSize, h);
    qsort(values, (size_t)n, sizeof values[0], by_int);
    vpi_printf((PLI_BYTE8 *)"%s: %s, typespec %s, same as %s.o %d, %ss %d, sizes",
               name, vpi_get_str(vpiType, obj),
               vpi_get_str(vpiType, vpi_handle(vpiTypespec, obj)),
               inst,
               vpi_compare_objects(vpi_handle(vpiTypespec, obj),
                                   port_net_typespec(inst)) ? 1 : 0,
               relation == vpiElement ? "element" : "member", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %d", values[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 ic_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    sizes("iv", vpiElement, "uv");
    sizes("is", vpiMember, "us");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ic";
    d.calltf = ic_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
