/* VPI application of test_vpi_net_properties (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_properties"

struct net_type {
    PLI_INT32 type;
    const char *name;
};

static const struct net_type net_types[] = {
    {vpiWire, "wire"}, {vpiTri, "tri"}, {vpiWand, "wand"}, {vpiWor, "wor"},
    {vpiTriAnd, "triand"}, {vpiTriOr, "trior"}, {vpiTri0, "tri0"}, {vpiTri1, "tri1"},
    {vpiSupply0, "supply0"}, {vpiSupply1, "supply1"}, {vpiUwire, "uwire"}, {vpiTriReg, "trireg"},
};

static const char *const nets[] = {
    "w", "v", "sv", "asc", "t", "wa", "wo", "ta", "tor", "t0", "t1", "s0", "s1", "uw", "tr",
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
    for (i = 0; i < (int)(sizeof net_types / sizeof net_types[0]); i++)
        if (net_types[i].type == vpi_get(vpiNetType, h))
            return net_types[i].name;
    return "other";
}

static void describe(const char *label, vpiHandle h)
{
    vpiHandle left = vpi_handle(vpiLeftRange, h), right = vpi_handle(vpiRightRange, h);

    vpi_printf("%s: %s, size %d, scalar %d, vector %d, signed %d", label, type_name(h),
               (int)vpi_get(vpiSize, h), (int)vpi_get(vpiScalar, h), (int)vpi_get(vpiVector, h),
               (int)vpi_get(vpiSigned, h));
    if (vpi_get(vpiVector, h) == 1 && left && right)
        vpi_printf(", range %d:%d", int_value(left), int_value(right));
    vpi_printf("\n");
}

static PLI_INT32 nets_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle v, bit, imp, index;
    PLI_BYTE8 *file;
    const char *base;
    int i;

    (void)user_data;
    for (i = 0; i < (int)(sizeof nets / sizeof nets[0]); i++) {
        vpiHandle h = find(nets[i]);
        if (h == NULL)
            vpi_printf("%s: not found\n", nets[i]);
        else
            describe(nets[i], h);
    }

    v = find("v");
    bit = v ? vpi_handle_by_index(v, 2) : NULL;
    if (bit == NULL) {
        vpi_printf("v[2]: not found\n");
    } else {
        index = vpi_handle(vpiIndex, bit);
        vpi_printf("v[2]: %s, size %d, scalar %d, vector %d, index %d, parent is v: %d\n",
                   vpi_get(vpiType, bit) == vpiNetBit ? "net bit" : "other type",
                   (int)vpi_get(vpiSize, bit), (int)vpi_get(vpiScalar, bit),
                   (int)vpi_get(vpiVector, bit), index ? int_value(index) : -1,
                   (int)vpi_compare_objects(vpi_handle(vpiParent, bit), v));
    }

    imp = find("imp");
    if (imp == NULL) {
        vpi_printf("imp: not found\n");
    } else {
        file = vpi_get_str(vpiFile, imp);
        base = file ? strrchr(file, '/') : NULL;
        vpi_printf("imp: %s, size %d, implicit %d, line %d, file %s\n", type_name(imp),
                   (int)vpi_get(vpiSize, imp), (int)vpi_get(vpiImplicitDecl, imp),
                   (int)vpi_get(vpiLineNo, imp), base ? base + 1 : file ? file : "(null)");
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_nets";
    d.calltf = nets_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
