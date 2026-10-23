/* VPI application of test_vpi_user_defined_net_kinds (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_user_defined_net_kinds"

enum { SIZE = 1, RANGES = 2 };

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
    case vpiShortRealNet: return "vpiShortRealNet";
    case vpiRealNet: return "vpiRealNet";
    case vpiByteNet: return "vpiByteNet";
    case vpiShortIntNet: return "vpiShortIntNet";
    case vpiIntNet: return "vpiIntNet";
    case vpiLongIntNet: return "vpiLongIntNet";
    case vpiIntegerNet: return "vpiIntegerNet";
    case vpiTimeNet: return "vpiTimeNet";
    case vpiBitNet: return "vpiBitNet";
    case vpiLogicNet: return "vpiLogicNet";
    case vpiPackedArrayNet: return "vpiPackedArrayNet";
    case vpiStructNet: return "vpiStructNet";
    case vpiUnionNet: return "vpiUnionNet";
    case vpiEnumNet: return "vpiEnumNet";
    default: return "other type";
    }
}

static void show(const char *name, int what)
{
    char full[96];
    vpiHandle h, it, r;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name(full, NULL);
    if (h == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    vpi_printf("%s: %s, vpiNettypeNet %d", name, kind(h), vpi_get(vpiNetType, h) == vpiNettypeNet);
    if (what & SIZE)
        vpi_printf(", size %d", (int)vpi_get(vpiSize, h));
    if (what & RANGES) {
        vpi_printf(", ranges");
        it = vpi_iterate(vpiRange, h);
        while (it && (r = vpi_scan(it)) != NULL)
            vpi_printf(" %d:%d", int_value(vpi_handle(vpiLeftRange, r)),
                       int_value(vpi_handle(vpiRightRange, r)));
        vpi_printf(", left %d right %d", int_value(vpi_handle(vpiLeftRange, h)),
                   int_value(vpi_handle(vpiRightRange, h)));
    }
    vpi_printf("\n");
}

static PLI_INT32 udn_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("nsr", 0);
    show("nr", 0);
    show("nb", SIZE);
    show("nsi", SIZE);
    show("ni", SIZE);
    show("nli", SIZE);
    show("nig", SIZE);
    show("nt", SIZE);
    show("nbit", SIZE | RANGES);
    show("nl", SIZE | RANGES);
    show("npa", SIZE | RANGES);
    show("ns", SIZE);
    show("nu", SIZE);
    show("ne", SIZE);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_udn";
    d.calltf = udn_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
