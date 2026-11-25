#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 show_ranges(p_cb_data callback)
{
    (void)callback;
    vpi_printf("object=%d property=%d callback=%d\n", vpiPackage, vpiTop, cbStartOfThread);
    vpi_printf("model=%d coverage=%d/%d\n", vpiImplication, vpiCoverageStart, vpiAssertKillCovered);
    vpi_printf("later assignments=%d/%d\n", vpiRestrict, vpiInterfaceTypespec);
    return 0;
}

static void register_test(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = show_ranges;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_test, 0};

#ifdef __cplusplus
}
#endif
