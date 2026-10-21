/* VPI application of test_vpi_systf_in_class_method (IEEE 1800-2023 36.4). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 note_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("class note\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_note";
    d.calltf = note_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
