#include <stddef.h>
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

static int initial_userdata;
static int restored_userdata;
static int restart_ended;

static PLI_INT32 end_restart(p_cb_data callback)
{
    restart_ended = callback->reason == cbEndOfRestart;
    return 0;
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle stage = iterator != NULL ? vpi_scan(iterator) : NULL;
    s_vpi_value phase = {0};
    (void)unused;
    if (stage == NULL)
        return 0;
    vpi_release_handle(iterator);
    phase.format = vpiIntVal;
    vpi_get_value(stage, &phase);
    switch (phase.value.integer) {
    case 0: {
        int status = vpi_put_userdata(call, &initial_userdata);
        vpi_printf("userdata attached=%d\n", status == 1 && vpi_get_userdata(call) == &initial_userdata);
        break;
    }
    case 1:
        vpi_printf("before restart same userdata=%d\n", vpi_get_userdata(call) == &initial_userdata);
        break;
    case 2: {
        int cleared = vpi_get_userdata(call) == NULL;
        int status = vpi_put_userdata(call, &restored_userdata);
        vpi_printf("restart callback=%d cleared=%d reassociated=%d\n",
                   restart_ended, cleared,
                   status == 1 && vpi_get_userdata(call) == &restored_userdata);
        break;
    }
    case 3:
        vpi_printf("later userdata matches=%d\n", vpi_get_userdata(call) == &restored_userdata);
        break;
    }
    return 0;
}

static void install(void)
{
    register_action(cbEndOfRestart, end_restart, NULL);
    register_probe("$probe_restart_userdata", observe);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
