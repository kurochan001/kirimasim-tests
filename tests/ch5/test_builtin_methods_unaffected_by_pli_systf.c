/* VPI application of test_builtin_methods_unaffected_by_pli_systf (IEEE 1800-2023 5.13, 36.3.2). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 ninety_nine_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;

    (void)user_data;
    v.format = vpiIntVal;
    v.value.integer = 99;
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    return 0;
}

static void register_one(const char *name)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = ninety_nine_calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    register_one("$size");
    register_one("$len");
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
