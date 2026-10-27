/* VPI application of test_36_extra_systf_name_dollar (IEEE 1800-2023 36.3).
   It registers a user system task under a name without the leading $, which
   §36.3 does not permit, so no such system task exists for the design. */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 should_not_run(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"a name without $ was accepted\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"vt_nodollar";
    d.calltf = should_not_run;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
