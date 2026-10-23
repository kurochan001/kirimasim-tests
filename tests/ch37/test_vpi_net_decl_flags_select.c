/* VPI application of test_vpi_net_decl_flags_select (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_decl_flags_select"

static vpiHandle net(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name(full, NULL);
}

static const char *strength(PLI_INT32 s)
{
    switch (s) {
    case vpiStrongDrive: return "vpiStrongDrive";
    case vpiPullDrive: return "vpiPullDrive";
    case vpiSmallCharge: return "vpiSmallCharge";
    case vpiLargeCharge: return "vpiLargeCharge";
    default: return "other";
    }
}

static void decl(const char *name)
{
    vpiHandle h = net(name);
    if (h == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    vpi_printf("%s: decl assign %d, explicit scalared %d, explicit vectored %d\n", name,
               (int)vpi_get(vpiNetDeclAssign, h), (int)vpi_get(vpiExplicitScalared, h),
               (int)vpi_get(vpiExplicitVectored, h));
}

static void bits(const char *name)
{
    vpiHandle h = net(name), it, b;
    int n = 0, same = 1;
    PLI_INT32 e = h ? vpi_get(vpiExpanded, h) : -2;
    it = h ? vpi_iterate(vpiBit, h) : NULL;
    while (it && (b = vpi_scan(it)) != NULL) {
        n++;
        if (vpi_get(vpiType, b) != vpiNetBit || vpi_get(vpiExpanded, b) != e)
            same = 0;
    }
    vpi_printf("%s: net bits %d, each with the vpiExpanded of the net %d\n", name, n,
               n > 0 && same);
}

static void rhs_select(const char *target)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = vpi_iterate(vpiContAssign, top), ca, lhs, rhs;
    while (it && (ca = vpi_scan(it)) != NULL) {
        lhs = vpi_handle(vpiLhs, ca);
        if (lhs == NULL || strcmp(vpi_get_str(vpiName, lhs), target) != 0)
            continue;
        rhs = vpi_handle(vpiRhs, ca);
        vpi_printf("right-hand side of %s: net %d, constant select %d\n", target,
                   rhs != NULL && vpi_get(vpiType, rhs) == vpiNet,
                   rhs ? (int)vpi_get(vpiConstantSelect, rhs) : -2);
        vpi_free_object(it);
        return;
    }
    vpi_printf("assignment to %s not found\n", target);
}

static PLI_INT32 flags_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle h, b, it;

    (void)user_data;
    decl("w_plain");
    decl("w_assign");
    decl("ws");
    decl("wv");
    bits("ws");
    bits("wv");
    h = net("wst");
    if (h != NULL)
        vpi_printf("wst: decl assign %d, strength0 %s, strength1 %s\n",
                   (int)vpi_get(vpiNetDeclAssign, h), strength(vpi_get(vpiStrength0, h)),
                   strength(vpi_get(vpiStrength1, h)));
    h = net("tcs");
    if (h != NULL)
        vpi_printf("tcs: charge strength %s\n", strength(vpi_get(vpiChargeStrength, h)));
    h = net("tcl");
    if (h != NULL)
        vpi_printf("tcl: charge strength %s\n", strength(vpi_get(vpiChargeStrength, h)));
    h = net("w_plain");
    if (h != NULL)
        vpi_printf("w_plain: parent NULL %d, constant select %d\n",
                   vpi_handle(vpiParent, h) == NULL, (int)vpi_get(vpiConstantSelect, h));
    h = net("ws");
    it = h ? vpi_iterate(vpiBit, h) : NULL;
    b = it ? vpi_scan(it) : NULL;
    if (b != NULL) {
        vpi_free_object(it);
        vpi_printf("a bit of ws: constant select %d\n", (int)vpi_get(vpiConstantSelect, b));
    }
    h = net("an");
    b = h ? vpi_handle_by_index(h, 1) : NULL;
    if (b != NULL)
        vpi_printf("an[1] by index: constant select %d\n", (int)vpi_get(vpiConstantSelect, b));
    rhs_select("y1");
    rhs_select("y2");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_flags";
    d.calltf = flags_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
