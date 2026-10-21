/* VPI application of test_vpi_get_property_values (IEEE 1800-2023 38.6). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *type_name(PLI_INT32 type)
{
    static char other[32];
    switch (type) {
    case vpiLogicVar: return "vpiLogicVar";
    case vpiIntVar: return "vpiIntVar";
    case vpiByteVar: return "vpiByteVar";
    case vpiLongIntVar: return "vpiLongIntVar";
    case vpiBitVar: return "vpiBitVar";
    case vpiRealVar: return "vpiRealVar";
    default:
        snprintf(other, sizeof other, "other type %d", (int)type);
        return other;
    }
}

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "test_vpi_get_property_values%s%s", *name ? "." : "", name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void integral(const char *name)
{
    vpiHandle h = by_name(name);
    if (h == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    vpi_printf("%s: %s, vpiSize %d, vpiSigned %d, vpiVector %d, vpiScalar %d\n", name,
               type_name(vpi_get(vpiType, h)), (int)vpi_get(vpiSize, h),
               (int)vpi_get(vpiSigned, h), (int)vpi_get(vpiVector, h),
               (int)vpi_get(vpiScalar, h));
}

static void times(const char *label, vpiHandle h)
{
    vpi_printf("%s: vpiTimeUnit %d, vpiTimePrecision %d\n", label,
               (int)vpi_get(vpiTimeUnit, h), (int)vpi_get(vpiTimePrecision, h));
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle rl = by_name("rl");

    (void)data;
    integral("r");
    integral("sr");
    integral("b");
    integral("i");
    integral("by");
    integral("li");
    integral("bt");
    if (rl != NULL)
        vpi_printf("rl: %s, vpiVector %d, vpiScalar %d\n", type_name(vpi_get(vpiType, rl)),
                   (int)vpi_get(vpiVector, rl), (int)vpi_get(vpiScalar, rl));
    times("NULL", NULL);
    times("top module", by_name(""));
    times("submodule", by_name("u"));
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
