/* VPI application of test_vpi_instance_arrays (IEEE 1800-2023 37.11). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_instance_arrays"

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int count(PLI_INT32 type, vpiHandle ref)
{
    vpiHandle it = vpi_iterate(type, ref);
    int n = 0;
    if (it != NULL)
        while (vpi_scan(it) != NULL)
            n++;
    return n;
}

static void describe(const char *name, PLI_INT32 array_type, const char *type_label,
                     PLI_INT32 element_relation)
{
    char full[64], array_name[64];
    vpiHandle a, e;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    a = vpi_handle_by_name(full, NULL);
    if (a == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    snprintf(array_name, sizeof array_name, "%s", vpi_get_str(vpiFullName, a));
    vpi_printf((PLI_BYTE8 *)"%s: %s %d, full name %s, size %d, range %d:%d, ranges %d, "
               "elements %d\n", name, type_label, vpi_get(vpiType, a) == array_type, array_name,
               (int)vpi_get(vpiSize, a), int_value(vpi_handle(vpiLeftRange, a)),
               int_value(vpi_handle(vpiRightRange, a)), count(vpiRange, a),
               count(element_relation, a));
    e = vpi_handle_by_index(a, 1);
    vpi_printf((PLI_BYTE8 *)"%s element 1: %s\n", name,
               e != NULL ? vpi_get_str(vpiFullName, e) : "not found");
}

static PLI_INT32 arrays_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    describe("u", vpiModuleArray, "module array", vpiModule);
    describe("g", vpiGateArray, "gate array", vpiPrimitive);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_arrays";
    d.calltf = arrays_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
