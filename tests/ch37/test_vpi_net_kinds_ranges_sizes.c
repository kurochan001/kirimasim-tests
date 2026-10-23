/* VPI application of test_vpi_net_kinds_ranges_sizes (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_kinds_ranges_sizes"

enum { RANGES = 1, BOUNDS = 2 };

static int int_value(vpiHandle expr)
{
    s_vpi_value v;
    if (expr == NULL)
        return -1000;
    v.format = vpiIntVal;
    vpi_get_value(expr, &v);
    return (int)v.value.integer;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiNet: return "logic net";
    case vpiIntegerNet: return "integer net";
    case vpiTimeNet: return "time net";
    case vpiStructNet: return "struct net";
    case vpiUnionNet: return "union net";
    case vpiEnumNet: return "enum net";
    case vpiPackedArrayNet: return "packed array net";
    case vpiArrayNet: return "array net";
    case vpiNetBit: return "net bit";
    default: return "other type";
    }
}

static void flags(vpiHandle h)
{
    vpi_printf("%s, size %d, scalar %d, vector %d", kind(h), (int)vpi_get(vpiSize, h),
               (int)vpi_get(vpiScalar, h), (int)vpi_get(vpiVector, h));
}

static void show(const char *name, int what)
{
    char full[96];
    vpiHandle h, it, r;
    int n = 0;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name(full, NULL);
    if (h == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    vpi_printf("%s: ", name);
    flags(h);
    if (what & RANGES) {
        vpi_printf(", ranges");
        it = vpi_iterate(vpiRange, h);
        while (it && (r = vpi_scan(it)) != NULL) {
            vpi_printf(" %d:%d", int_value(vpi_handle(vpiLeftRange, r)),
                       int_value(vpi_handle(vpiRightRange, r)));
            n++;
        }
        if (n == 0)
            vpi_printf(" none");
    }
    if (what & BOUNDS)
        vpi_printf(", left %d right %d", int_value(vpi_handle(vpiLeftRange, h)),
                   int_value(vpi_handle(vpiRightRange, h)));
    if (vpi_get(vpiType, h) == vpiArrayNet) {
        const char *s = vpi_get_str(vpiType, h);
        vpi_printf(", type string vpiArrayNet or vpiNetArray %d",
                   s != NULL && (strcmp(s, "vpiArrayNet") == 0 || strcmp(s, "vpiNetArray") == 0));
    }
    if (vpi_get(vpiType, h) == vpiNet) {
        const char *s = vpi_get_str(vpiType, h);
        vpi_printf(", type string vpiNet or vpiLogicNet %d",
                   s != NULL && (strcmp(s, "vpiNet") == 0 || strcmp(s, "vpiLogicNet") == 0));
    }
    vpi_printf("\n");
}

static void bits(const char *name)
{
    char full[96];
    vpiHandle h, it, b;
    int n = 0, i = 0;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name(full, NULL);
    it = h ? vpi_iterate(vpiBit, h) : NULL;
    while (it && (b = vpi_scan(it)) != NULL) {
        n++;
        if (vpi_get(vpiType, b) == vpiNetBit && vpi_get(vpiSize, b) == 1
            && vpi_get(vpiScalar, b) == 1 && vpi_get(vpiVector, b) == 0)
            i++;
    }
    vpi_printf("%s bits: %d, net bits of size 1, scalar 1, vector 0: %d\n", name, n, i);
}

static PLI_INT32 nets_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("s1", RANGES);
    show("lv", RANGES | BOUNDS);
    show("w4", RANGES | BOUNDS);
    bits("w4");
    show("wi", 0);
    show("wt", 0);
    show("psn", 0);
    show("usn", 0);
    show("pun", 0);
    show("enn", 0);
    show("en1", 0);
    show("pan", RANGES | BOUNDS);
    show("pae", RANGES | BOUNDS);
    show("an", RANGES);
    show("sn", RANGES);
    show("apn", RANGES);
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
