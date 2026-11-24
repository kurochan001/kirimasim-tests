#include <stddef.h>
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

static int before_hits;
static int surviving_old_hits;
static int fresh_hits;
static int start_hits;
static int end_hits;
static s_vpi_time time_data = {.type = vpiSuppressTime};
static s_vpi_value value_data = {.format = vpiSuppressVal};

static PLI_INT32 before_restart(p_cb_data callback)
{
    (void)callback;
    ++start_hits;
    vpi_printf("start restart reason=%d\n", callback->reason == cbStartOfRestart);
    return 0;
}

static PLI_INT32 after_restart(p_cb_data callback)
{
    (void)callback;
    ++end_hits;
    vpi_printf("end restart reason=%d\n", callback->reason == cbEndOfRestart);
    return 0;
}

static PLI_INT32 stale_end_of_simulation(p_cb_data callback)
{
    (void)callback;
    vpi_printf("unexpected end-of-simulation callback from before restart\n");
    return 0;
}

static PLI_INT32 old_change(p_cb_data callback)
{
    (void)callback;
    if (end_hits)
        ++surviving_old_hits;
    else
        ++before_hits;
    return 0;
}

static PLI_INT32 fresh_change(p_cb_data callback)
{
    (void)callback;
    ++fresh_hits;
    return 0;
}

static void watch(vpiHandle object, PLI_INT32 (*routine)(p_cb_data))
{
    s_cb_data callback = {0};
    callback.reason = cbValueChange;
    callback.cb_rtn = routine;
    callback.obj = object;
    callback.time = &time_data;
    callback.value = &value_data;
    vpi_register_cb(&callback);
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    s_vpi_value phase = {0};
    (void)unused;
    if (iterator == NULL)
        return 0;
    vpiHandle mode = vpi_scan(iterator);
    if (mode == NULL)
        return 0;
    vpiHandle object = vpi_scan(iterator);
    if (object == NULL)
        return 0;
    vpi_release_handle(iterator);
    phase.format = vpiIntVal;
    vpi_get_value(mode, &phase);
    switch (phase.value.integer) {
    case 0:
        watch(object, old_change);
        break;
    case 1:
        watch(object, fresh_change);
        break;
    case 2:
        vpi_printf("retained start=%d end=%d old before=%d old after=%d new after=%d\n",
                   start_hits, end_hits, before_hits, surviving_old_hits, fresh_hits);
        break;
    }
    return 0;
}

static void install(void)
{
    register_action(cbStartOfRestart, before_restart, NULL);
    register_action(cbEndOfRestart, after_restart, NULL);
    register_action(cbEndOfSimulation, stale_end_of_simulation, NULL);
    register_probe("$probe_restart_callbacks", observe);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
