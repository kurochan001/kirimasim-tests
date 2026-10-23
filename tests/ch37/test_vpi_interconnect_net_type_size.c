/* VPI application of test_vpi_interconnect_net_type_size (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interconnect_net_type_size"

static const char *net_type(PLI_INT32 t)
{
    switch (t) {
    case vpiInterconnect: return "vpiInterconnect";
    case vpiWand: return "vpiWand";
    case vpiTri1: return "vpiTri1";
    case vpiWire: return "vpiWire";
    default: return "other";
    }
}

static PLI_INT32 ic_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle iw = vpi_handle_by_name((PLI_BYTE8 *)TOP ".iw", NULL);
    vpiHandle ia = vpi_handle_by_name((PLI_BYTE8 *)TOP ".ia", NULL);

    (void)user_data;
    if (iw != NULL)
        vpi_printf("iw: interconnect net %d, net type %s, resolved net type %s, size %d\n",
                   vpi_get(vpiType, iw) == vpiInterconnectNet, net_type(vpi_get(vpiNetType, iw)),
                   net_type(vpi_get(vpiResolvedNetType, iw)), (int)vpi_get(vpiSize, iw));
    if (ia != NULL)
        vpi_printf("ia: interconnect array %d, net type %s, size %d, typespec NULL %d\n",
                   vpi_get(vpiType, ia) == vpiInterconnectArray, net_type(vpi_get(vpiNetType, ia)),
                   (int)vpi_get(vpiSize, ia), vpi_handle(vpiTypespec, ia) == NULL);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ic";
    d.calltf = ic_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
