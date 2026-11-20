#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define ROOM 8

typedef struct watched_thread {
    int tag, used, identity;
    PLI_UINT32 times[ROOM];
    int markers[ROOM];
    vpiHandle frame, thread, registration;
    s_vpi_time requested_time;
    s_vpi_value requested_value;
} watched_thread;

static watched_thread watched[2];

static int read_int(vpiHandle handle)
{
    s_vpi_value value;
    memset(&value, 0, sizeof value);
    value.format = vpiIntVal;
    vpi_get_value(handle, &value);
    return value.value.integer;
}

static int argument_tag(void)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle argument = iterator != NULL ? vpi_scan(iterator) : NULL;
    int tag = argument != NULL ? read_int(argument) : -1;
    if (argument != NULL)
        vpi_release_handle(iterator);
    return tag;
}

static vpiHandle marker_of(vpiHandle frame)
{
    vpiHandle iterator = frame != NULL ? vpi_iterate(vpiAutomatics, frame) : NULL;
    vpiHandle object, found = NULL;
    while (iterator != NULL && (object = vpi_scan(iterator)) != NULL) {
        const char *name = vpi_get_str(vpiName, object);
        if (name != NULL && strcmp(name, "marker") == 0)
            found = object;
    }
    return found;
}

static PLI_INT32 resumed(p_cb_data cb)
{
    watched_thread *state = (watched_thread *)cb->user_data;
    vpiHandle marker = marker_of(state->frame);
    int slot = state->used++;

    if (slot >= ROOM) {
        state->identity = 0;
        return 0;
    }
    state->times[slot] = cb->time != NULL ? cb->time->low : 0;
    state->markers[slot] = marker != NULL ? read_int(marker) : -1;
    if (cb->reason != cbEnterThread || cb->obj == NULL || state->thread == NULL ||
        !vpi_compare_objects(cb->obj, state->thread) || cb->time == NULL ||
        cb->time->type != vpiSimTime || cb->time->high != 0 || marker == NULL)
        state->identity = 0;
    return 0;
}

static PLI_INT32 watch_resume(PLI_BYTE8 *user_data)
{
    int tag = argument_tag();
    int index = tag == 91 ? 0 : tag == 52 ? 1 : -1;
    watched_thread *state;
    s_cb_data registration;

    (void)user_data;
    if (index < 0) {
        vpi_printf((PLI_BYTE8 *)"unexpected worker tag\n");
        return 0;
    }
    state = &watched[index];
    memset(state, 0, sizeof *state);
    state->tag = tag;
    state->identity = 1;
    state->frame = vpi_handle(vpiFrame, NULL);
    state->thread = state->frame != NULL ? vpi_handle(vpiThread, state->frame) : NULL;
    if (state->frame == NULL || state->thread == NULL || marker_of(state->frame) == NULL) {
        state->identity = 0;
        vpi_printf((PLI_BYTE8 *)"worker frame or marker missing\n");
        return 0;
    }
    state->requested_time.type = vpiSimTime;
    state->requested_value.format = vpiSuppressVal;
    memset(&registration, 0, sizeof registration);
    registration.reason = cbEnterThread;
    registration.cb_rtn = resumed;
    registration.obj = state->thread;
    registration.time = &state->requested_time;
    registration.value = &state->requested_value;
    registration.user_data = (PLI_BYTE8 *)state;
    state->registration = vpi_register_cb(&registration);
    if (state->registration == NULL)
        vpi_printf((PLI_BYTE8 *)"thread callback not registered\n");
    return 0;
}

static PLI_INT32 unwatch_resume(PLI_BYTE8 *user_data)
{
    int tag = argument_tag();
    int index = tag == 91 ? 0 : tag == 52 ? 1 : -1;
    watched_thread *state;

    (void)user_data;
    if (index < 0)
        return 0;
    state = &watched[index];
    if (state->registration != NULL && !vpi_remove_cb(state->registration))
        vpi_printf((PLI_BYTE8 *)"thread callback removal failed\n");
    state->registration = NULL;
    state->frame = NULL;
    state->thread = NULL;
    return 0;
}

static PLI_INT32 report_resume(PLI_BYTE8 *user_data)
{
    int index, slot;
    (void)user_data;
    for (index = 0; index < 2; index++) {
        watched_thread *state = &watched[index];
        int count = state->used < ROOM ? state->used : ROOM;
        vpi_printf((PLI_BYTE8 *)"tag=%d callbacks=%d times=", state->tag, state->used);
        for (slot = 0; slot < count; slot++)
            vpi_printf((PLI_BYTE8 *)"%s%u", slot ? "," : "", state->times[slot]);
        vpi_printf((PLI_BYTE8 *)" markers=");
        for (slot = 0; slot < count; slot++)
            vpi_printf((PLI_BYTE8 *)"%s%d", slot ? "," : "", state->markers[slot]);
        vpi_printf((PLI_BYTE8 *)" identity=%d\n", state->identity);
    }
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data task;
    memset(&task, 0, sizeof task);
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)name;
    task.calltf = calltf;
    vpi_register_systf(&task);
}

static void register_application(void)
{
    add_task("$vt_watch_resume", watch_resume);
    add_task("$vt_unwatch_resume", unwatch_resume);
    add_task("$vt_report_resume", report_resume);
}

void (*vlog_startup_routines[])(void) = {register_application, 0};

#ifdef __cplusplus
}
#endif
