#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 verify_codes(p_cb_data cb)
{
    (void)cb;
    vpi_printf("base constant=%d module=%d reg=%d\n", vpiConstant, vpiModule, vpiReg);
    vpi_printf("extension package=%d alias logic=%d alias matches=%d\n",
               vpiPackage, vpiLogicVar, vpiLogicVar == vpiReg);
    return 0;
}

static void install(void)
{
    s_cb_data cb = {0};
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = verify_codes;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
