/* VPI application of test_36_extra_timing_check_not_systf
   (IEEE 1800-2023 36.3.2). It registers a user system task under the name of
   the timing check $setup; §36.3.2 says a timing check is not a system task
   and cannot be overridden, so the registration does not make $setup a task. */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 should_not_run(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"the timing check was overridden\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$setup";
    d.calltf = should_not_run;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
