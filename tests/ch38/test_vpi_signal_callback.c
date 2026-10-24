/* VPI application of test_vpi_signal_callback (IEEE 1800-2023 38.36.3). */
#include <signal.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char term_tag[] = "term";
static vpiHandle signal_cb;
static int calls, right_reason, right_user_data;

static PLI_INT32 on_signal(p_cb_data cb)
{
    calls++;
    right_reason = cb->reason == cbSignal;
    right_user_data = cb->user_data == term_tag;
    return 0;
}

static PLI_INT32 raise_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (signal_cb == NULL) {
        vpi_printf((PLI_BYTE8 *)"cbSignal was not registered\n");
        return 0;
    }
    raise(SIGTERM);
    return 0;
}

static PLI_INT32 check_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"cbSignal callback calls: %d, reason cbSignal %d, user_data term %d\n",
               calls, right_reason, right_user_data);
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

/* A startup routine may place only the reasons of 36.10.2, so cbSignal is placed
   at the start of the simulation. */
static PLI_INT32 start_of_simulation(p_cb_data start)
{
    s_cb_data cb;

    (void)start;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbSignal;
    cb.cb_rtn = on_signal;
    cb.index = SIGTERM;
    cb.user_data = term_tag;
    signal_cb = vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);
    add_task("$vt_raise", raise_calltf);
    add_task("$vt_check", check_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
