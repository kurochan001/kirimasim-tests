/* VPI application of test_vpi_variable_properties (IEEE 1800-2023 37.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_properties"

struct var_type {
    PLI_INT32 type;
    const char *name;
};

static const struct var_type var_types[] = {
    {vpiReg, "logic"}, {vpiIntegerVar, "integer"}, {vpiTimeVar, "time"}, {vpiIntVar, "int"},
    {vpiShortIntVar, "shortint"}, {vpiLongIntVar, "longint"}, {vpiByteVar, "byte"},
    {vpiBitVar, "bit"}, {vpiRealVar, "real"},
};

static const char *const vars[] = {
    "r", "rv", "rs", "la", "i", "t", "ii", "si", "li", "by", "b", "bv", "re",
};

static vpiHandle find(const char *name)
{
    char full[64];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name(full, NULL);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *type_name(vpiHandle h)
{
    int i;
    for (i = 0; i < (int)(sizeof var_types / sizeof var_types[0]); i++)
        if (var_types[i].type == vpi_get(vpiType, h))
            return var_types[i].name;
    return "other";
}

static PLI_INT32 variables_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle rv, bit, index, init, expr;
    int i;

    (void)user_data;
    for (i = 0; i < (int)(sizeof vars / sizeof vars[0]); i++) {
        vpiHandle h = find(vars[i]), left, right;
        if (h == NULL) {
            vpi_printf("%s: not found\n", vars[i]);
            continue;
        }
        vpi_printf("%s: %s", vars[i], type_name(h));
        if (vpi_get(vpiType, h) != vpiRealVar)
            vpi_printf(", size %d, signed %d", (int)vpi_get(vpiSize, h),
                       (int)vpi_get(vpiSigned, h));
        vpi_printf(", scalar %d, vector %d", (int)vpi_get(vpiScalar, h),
                   (int)vpi_get(vpiVector, h));
        left = vpi_handle(vpiLeftRange, h);
        right = vpi_handle(vpiRightRange, h);
        if ((vpi_get(vpiType, h) == vpiReg || vpi_get(vpiType, h) == vpiBitVar)
            && vpi_get(vpiVector, h) == 1 && left && right)
            vpi_printf(", range %d:%d", int_value(left), int_value(right));
        vpi_printf("\n");
    }

    rv = find("rv");
    bit = rv ? vpi_handle_by_index(rv, 3) : NULL;
    if (bit == NULL) {
        vpi_printf("rv[3]: not found\n");
    } else {
        index = vpi_handle(vpiIndex, bit);
        vpi_printf("rv[3]: %s, size %d, scalar %d, vector %d, value %d, index %d, "
                   "parent is rv: %d\n",
                   vpi_get(vpiType, bit) == vpiRegBit ? "var bit" : "other type",
                   (int)vpi_get(vpiSize, bit), (int)vpi_get(vpiScalar, bit),
                   (int)vpi_get(vpiVector, bit), int_value(bit), index ? int_value(index) : -1,
                   (int)vpi_compare_objects(vpi_handle(vpiParent, bit), rv));
    }

    init = find("init");
    expr = init ? vpi_handle(vpiExpr, init) : NULL;
    if (expr == NULL)
        vpi_printf("init: no initialization expression\n");
    else
        vpi_printf("init: initialization expression %d\n", int_value(expr));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_variables";
    d.calltf = variables_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
