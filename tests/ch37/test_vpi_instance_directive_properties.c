/* VPI application of test_vpi_instance_directive_properties (IEEE 1800-2023 37.10). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_instance_directive_properties"

static const char *net_type(PLI_INT32 t)
{
    switch (t) {
    case vpiWire: return "vpiWire";
    case vpiTri1: return "vpiTri1";
    case vpiWand: return "vpiWand";
    case vpiNone: return "vpiNone";
    default: return "other";
    }
}

static const char *drive(PLI_INT32 d)
{
    switch (d) {
    case vpiHighZ: return "vpiHighZ";
    case vpiPull1: return "vpiPull1";
    case vpiPull0: return "vpiPull0";
    default: return "other";
    }
}

static void show(const char *label, const char *path)
{
    vpiHandle inst = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);

    if (inst == NULL) {
        vpi_printf("%s not found\n", label);
        return;
    }
    vpi_printf("%s: top %d, array member %d, default net type %s, unconnected drive %s, "
               "delay mode none %d, protected %d\n",
               label, (int)vpi_get(vpiTop, inst), (int)vpi_get(vpiArrayMember, inst),
               net_type(vpi_get(vpiDefNetType, inst)), drive(vpi_get(vpiUnconnDrive, inst)),
               vpi_get(vpiDefDelayMode, inst) == vpiDelayModeNone,
               (int)vpi_get(vpiProtected, inst));
}

static PLI_INT32 props_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("top", TOP);
    show("u1", TOP ".u1");
    show("arr[1]", TOP ".arr[1]");
    show("arr[0]", TOP ".arr[0]");
    show("u0", TOP ".u0");
    show("un", TOP ".un");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_props";
    d.calltf = props_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
