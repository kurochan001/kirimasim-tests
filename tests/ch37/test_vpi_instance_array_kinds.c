/* VPI application of test_vpi_instance_array_kinds (IEEE 1800-2023 37.11,
 * 37.5, 37.6, 37.9, 37.35). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_instance_array_kinds"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int count(PLI_INT32 type, vpiHandle ref)
{
    vpiHandle it = ref ? vpi_iterate(type, ref) : NULL;
    int n = 0;
    while (it != NULL && vpi_scan(it) != NULL)
        n++;
    return n;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h ? vpi_get_str(vpiName, h) : NULL;
    return s ? s : "(null)";
}

static void module_array(void)
{
    vpiHandle u = by_name(".u"), it, h, list, lhs;
    PLI_INT32 idx[2] = {0, 3};

    if (u == NULL) {
        vpi_printf((PLI_BYTE8 *)"u: not found\n");
        return;
    }
    vpi_printf((PLI_BYTE8 *)"u: module array %d, range %d:%d, ranges:",
               vpi_get(vpiType, u) == vpiModuleArray, int_value(vpi_handle(vpiLeftRange, u)),
               int_value(vpi_handle(vpiRightRange, u)));
    it = vpi_iterate(vpiRange, u);
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        vpi_printf((PLI_BYTE8 *)" %d:%d", int_value(vpi_handle(vpiLeftRange, h)),
                   int_value(vpi_handle(vpiRightRange, h)));
    vpi_printf((PLI_BYTE8 *)"\n");
    list = vpi_handle(vpiExpr, u);
    vpi_printf((PLI_BYTE8 *)"u: connections are a list operation %d\n",
               list != NULL && vpi_get(vpiType, list) == vpiOperation &&
                   vpi_get(vpiOpType, list) == vpiListOp);
    vpi_printf((PLI_BYTE8 *)"u: parameter assignments:");
    it = vpi_iterate(vpiParamAssign, u);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        lhs = vpi_handle(vpiLhs, h);
        vpi_printf((PLI_BYTE8 *)" %s = %d by name %d", name_of(lhs),
                   int_value(vpi_handle(vpiRhs, h)), (int)vpi_get(vpiConnByName, h));
    }
    vpi_printf((PLI_BYTE8 *)"\n");
    h = vpi_handle_by_multi_index(u, 2, idx);
    vpi_printf((PLI_BYTE8 *)"u[0][3] by multiple index: %s\n",
               h && vpi_get_str(vpiFullName, h) ? vpi_get_str(vpiFullName, h) : "(null)");
}

/* An element of an array by index, with its vpiIndex. */
static void element(const char *name, PLI_INT32 array_type, PLI_INT32 index)
{
    vpiHandle a = by_name(name), e;
    if (a == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name + 1);
        return;
    }
    e = vpi_handle_by_index(a, index);
    vpi_printf((PLI_BYTE8 *)"%s: array type matches %d, element %d has index %d\n", name + 1,
               vpi_get(vpiType, a) == array_type, (int)index,
               e ? int_value(vpi_handle(vpiIndex, e)) : -1);
}

static void single(const char *name)
{
    vpiHandle h = by_name(name);
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name + 1);
    else
        vpi_printf((PLI_BYTE8 *)"%s: index is NULL %d\n", name + 1,
                   vpi_handle(vpiIndex, h) == NULL);
}

static PLI_INT32 arrays_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = by_name(""), g = by_name(".g");

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"arrays of the module: module %d, interface %d, program %d, "
                            "primitive %d\n",
               count(vpiModuleArray, top), count(vpiInterfaceArray, top),
               count(vpiProgramArray, top), count(vpiPrimitiveArray, top));
    module_array();
    element(".ifs", vpiInterfaceArray, 1);
    single(".one");
    element(".pa", vpiProgramArray, 3);
    single(".po");
    element(".g", vpiGateArray, 0);
    single(".go");
    vpi_printf((PLI_BYTE8 *)"g: delay %d\n", g ? int_value(vpi_handle(vpiDelay, g)) : -1);
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
