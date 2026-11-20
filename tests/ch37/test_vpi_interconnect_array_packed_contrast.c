/* IEEE 1800-2023 37.24 B002: query both values of vpiPacked. */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interconnect_array_packed_contrast"

static int same(vpiHandle a, vpiHandle b)
{
    return a && b && vpi_compare_objects(a, b) ? 1 : 0;
}

static int bound(vpiHandle a, int relation)
{
    s_vpi_value v;
    vpiHandle h = vpi_handle(relation, a);
    if (!h)
        return -99;
    memset(&v, 0, sizeof v);
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void report(const char *name, vpiHandle top)
{
    char path[160];
    vpiHandle a;
    snprintf(path, sizeof path, "%s.%s", TOP, name);
    a = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    if (!a) {
        vpi_printf((PLI_BYTE8 *)"%s: missing\n", name);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: interconnect array %d, owner top %d, packed %d, range %d:%d, elements %d\n",
               name, vpi_get(vpiType, a) == vpiInterconnectArray,
               same(vpi_handle(vpiModule, a), top), (int)vpi_get(vpiPacked, a),
               bound(a, vpiLeftRange), bound(a, vpiRightRange),
               (int)vpi_get(vpiSize, a));
}

static PLI_INT32 calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    (void)user_data;
    report("packed_link", top);
    report("unpacked_link", top);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_packed_contrast";
    d.calltf = calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
