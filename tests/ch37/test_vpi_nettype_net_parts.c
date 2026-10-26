/* VPI application of test_vpi_nettype_net_parts (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_nettype_net_parts"

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void net_type(const char *label, vpiHandle h)
{
    vpi_printf((PLI_BYTE8 *)"%s: netType %s %d, size %d", label,
               sprop(vpiNetType, h), (int)vpi_get(vpiNetType, h),
               (int)vpi_get(vpiSize, h));
}

static void ranges(vpiHandle h)
{
    vpiHandle it = h != NULL ? vpi_iterate(vpiRange, h) : NULL, r;
    int n = 0;

    vpi_printf((PLI_BYTE8 *)", ranges");
    while (it != NULL && (r = vpi_scan(it)) != NULL) {
        vpiHandle l = vpi_handle(vpiLeftRange, r);
        vpiHandle rr = vpi_handle(vpiRightRange, r);
        s_vpi_value v;
        int left = -1000, right = -1000;

        v.format = vpiIntVal;
        if (l != NULL) {
            vpi_get_value(l, &v);
            left = (int)v.value.integer;
        }
        v.format = vpiIntVal;
        if (rr != NULL) {
            vpi_get_value(rr, &v);
            right = (int)v.value.integer;
        }
        vpi_printf((PLI_BYTE8 *)" %d:%d", left, right);
        n++;
    }
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none");
}

static PLI_INT32 ntnets_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle w = find("w"), wa = find("wa"), it, bit = NULL;

    (void)user_data;
    net_type("b", find("b"));
    vpi_printf((PLI_BYTE8 *)"\n");
    net_type("w", w);
    {
        vpiHandle dit = w != NULL ? vpi_iterate(vpiDriver, w) : NULL, d;
        int n = 0;

        while (dit != NULL && (d = vpi_scan(dit)) != NULL)
            n++;
        vpi_printf((PLI_BYTE8 *)", drivers %d", n);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
    it = w != NULL ? vpi_iterate(vpiBit, w) : NULL;
    while (it != NULL && (bit = vpi_scan(it)) != NULL)
        if (vpi_get(vpiIndex, bit) == 0)
            break;
    net_type("w[0]", bit);
    vpi_printf((PLI_BYTE8 *)", drivers NULL %d, local drivers NULL %d\n",
               bit != NULL && vpi_iterate(vpiDriver, bit) == NULL,
               bit != NULL && vpi_iterate(vpiLocalDriver, bit) == NULL);
    net_type("wa", wa);
    ranges(wa);
    vpi_printf((PLI_BYTE8 *)"\n");
    {
        int i;
        for (i = 0; i < 2; i++) {
            char label[16];
            vpiHandle e = wa != NULL ? vpi_handle_by_index(wa, i) : NULL;
            snprintf(label, sizeof label, "wa[%d]", i);
            net_type(label, e);
            vpi_printf((PLI_BYTE8 *)", array member %d\n",
                       e != NULL ? (int)vpi_get(vpiArrayMember, e) : -1);
        }
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ntnets";
    d.calltf = ntnets_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
