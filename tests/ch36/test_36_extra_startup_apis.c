/* VPI application of test_36_extra_startup_apis (IEEE 1800-2023 36.10.2).
   The startup routine calls only vpi_register_systf and vpi_register_cb. */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 say_hello(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"$vt_from_startup ran\n");
    return 0;
}

static PLI_INT32 on_end_of_compile(p_cb_data cb)
{
    (void)cb;
    vpi_printf((PLI_BYTE8 *)"end of compile callback\n");
    return 0;
}

static PLI_INT32 on_start_of_simulation(p_cb_data cb)
{
    (void)cb;
    vpi_printf((PLI_BYTE8 *)"start of simulation callback\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    s_cb_data cb;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_from_startup";
    d.calltf = say_hello;
    vpi_register_systf(&d);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfCompile;
    cb.cb_rtn = on_end_of_compile;
    vpi_register_cb(&cb);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
