#include <stddef.h>
#include "../ch38/checkpoint_fixtures/action_callback.h"

#ifdef RESTART_HANDLE_TABLE
#include <dlfcn.h>
#endif

enum handle_kind {
    SCOPE, WATCHED, BIT, EVENT, CHANGE, FINISH, START_RESTART, END_RESTART, HANDLE_COUNT
};
static vpiHandle previous[HANDLE_COUNT];
static int old_before;
static int old_after;
static int fresh_hits;
static int start_hits;
static int end_hits;
static s_vpi_time watch_time = {.type = vpiSuppressTime};
static s_vpi_value watch_value = {.format = vpiSuppressVal};

#ifdef RESTART_HANDLE_TABLE
/* Inspect Ghost's lookup table without calling the public VPI on old handles. */
static void sample_handle_table(const char *phase)
{
    void *(*instance)(void) = dlsym(RTLD_DEFAULT, "_ZN9sukimasim3vpi12VPIInterface11getInstanceEv");
    void *(*lookup)(void *, vpiHandle) = dlsym(RTLD_DEFAULT, "_ZN9sukimasim3vpi12VPIInterface13getHandleImplEPj");
    if (!instance || !lookup)
        return;

    void *interface = instance();
    char present[HANDLE_COUNT + 1];
    for (int index = 0; index < HANDLE_COUNT; ++index)
        present[index] = previous[index] && lookup(interface, previous[index]) ? '1' : '0';
    present[HANDLE_COUNT] = '\0';
    vpi_printf("restart table %s=%s\n", phase, present);
}
#else
static void sample_handle_table(const char *phase) { (void)phase; }
#endif

static PLI_INT32 before_restart(p_cb_data callback)
{
    sample_handle_table("start");
    ++start_hits;
    vpi_printf("start restart reason=%d\n", callback->reason == cbStartOfRestart);
    return 0;
}

static PLI_INT32 after_restart(p_cb_data callback)
{
    sample_handle_table("end");
    ++end_hits;
    vpi_printf("end restart reason=%d\n", callback->reason == cbEndOfRestart);
    return 0;
}

static PLI_INT32 old_change(p_cb_data callback)
{
    (void)callback;
    if (end_hits)
        ++old_after;
    else if (!start_hits)
        ++old_before;
    return 0;
}

static PLI_INT32 fresh_change(p_cb_data callback)
{
    (void)callback;
    ++fresh_hits;
    return 0;
}

static PLI_INT32 old_finish(p_cb_data callback)
{
    (void)callback;
    vpi_printf("old end-of-simulation callback fired\n");
    return 0;
}

static vpiHandle watch(vpiHandle object, PLI_INT32 (*routine)(p_cb_data))
{
    s_cb_data callback = {
        .reason = cbValueChange,
        .cb_rtn = routine,
        .obj = object,
        .time = &watch_time,
        .value = &watch_value,
    };
    return vpi_register_cb(&callback);
}

static void arm(vpiHandle call, vpiHandle watched, vpiHandle pending)
{
    s_vpi_time delay = {.type = vpiSimTime, .low = 50};
    s_vpi_value value = {.format = vpiIntVal, .value.integer = 19};

    previous[SCOPE] = vpi_handle(vpiScope, call);
    previous[WATCHED] = watched;
    previous[BIT] = vpi_handle_by_index(watched, 0);
    previous[EVENT] = vpi_put_value(pending, &value, &delay, vpiTransportDelay | vpiReturnEvent);
    previous[CHANGE] = watch(watched, old_change);
    previous[FINISH] = register_action(cbEndOfSimulation, old_finish, NULL);
    int event_queued = previous[EVENT] != NULL;
#ifdef vpiScheduled
    event_queued = event_queued && vpi_get(vpiScheduled, previous[EVENT]) == 1;
#endif
    vpi_printf("armed scope=%d watched=%d bit=%d event=%d callbacks=%d%d%d%d\n",
               previous[SCOPE] && vpi_get(vpiType, previous[SCOPE]) == vpiModule,
               vpi_get(vpiSize, watched) == 8,
               previous[BIT] && vpi_get(vpiSize, previous[BIT]) == 1,
               event_queued,
               previous[CHANGE] != NULL, previous[FINISH] != NULL,
               previous[START_RESTART] != NULL, previous[END_RESTART] != NULL);
    sample_handle_table("before");
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle arguments = call ? vpi_iterate(vpiArgument, call) : NULL;
    if (!arguments)
        return 0;
    vpiHandle phase = vpi_scan(arguments);
    vpiHandle watched = vpi_scan(arguments);
    vpiHandle pending = vpi_scan(arguments);
    if (!pending)
        return 0;
    vpi_release_handle(arguments);

    s_vpi_value value = {.format = vpiIntVal};
    vpi_get_value(phase, &value);
    switch (value.value.integer) {
    case 0:
        arm(call, watched, pending);
        break;
    case 1:
        sample_handle_table("resumed");
        vpi_printf("fresh register=%d callback=%d\n",
                   vpi_get(vpiSize, watched) == 8, watch(watched, fresh_change) != NULL);
        break;
    case 2:
        vpi_printf("restart hits=%d,%d old pre=%d old post=%d fresh=%d\n",
                   start_hits, end_hits, old_before, old_after, fresh_hits);
        break;
    }
    return 0;
}

static void install(void)
{
    previous[START_RESTART] = register_action(cbStartOfRestart, before_restart, NULL);
    previous[END_RESTART] = register_action(cbEndOfRestart, after_restart, NULL);
    register_probe("$observe_restart_handles", observe);
}

void (*vlog_startup_routines[])(void) = {install, NULL};
