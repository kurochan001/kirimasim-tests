#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

static void frame_values(vpiHandle frame, const char *stage)
{
    vpiHandle thread = frame ? vpi_handle(vpiThread, frame) : NULL;
    vpiHandle iterator = frame ? vpi_iterate(vpiAutomatics, frame) : NULL;
    int argument_found = 0, local_found = 0;
    int argument = 0, local_value = 0;
    vpiHandle member;
    while (iterator && (member = vpi_scan(iterator)) != NULL) {
        const char *name = vpi_get_str(vpiName, member);
        const int is_argument = name && strcmp(name, "argument") == 0;
        const int is_local = name && strcmp(name, "local_value") == 0;
        s_vpi_value value = {0};
        value.format = vpiIntVal;
        if (is_argument || is_local)
            vpi_get_value(member, &value);
        if (is_argument) {
            argument_found = 1;
            argument = value.value.integer;
        } else if (is_local) {
            local_found = 1;
            local_value = value.value.integer;
        }
    }
    printf("VPI_START %s frame=%p thread=%p type=%d argument=%d/%d local=%d/%d\n",
           stage, (void *)frame, (void *)thread, frame && vpi_get(vpiType, frame) == vpiFrame,
           argument_found, argument, local_found, local_value);
    fflush(stdout);
}

static PLI_INT32 on_start(p_cb_data event)
{
    if (event->reason == cbStartOfThread) {
        printf("VPI_START thread thread=%p type=%d\n", (void *)event->obj,
               event->obj && vpi_get(vpiType, event->obj) == vpiThread);
        fflush(stdout);
    } else if (event->reason == cbStartOfFrame) {
        frame_values(event->obj, "callback");
    }
    return 0;
}

/* Called by the verifier after allocation and before dispatch. */
int register_start_witness(void *object, int reason)
{
    static s_vpi_time time = {0};
    static s_vpi_value value = {0};
    time.type = vpiSuppressTime;
    value.format = vpiSuppressVal;
    s_cb_data event = {0};
    event.reason = reason;
    event.obj = (vpiHandle)object;
    event.cb_rtn = on_start;
    event.time = &time;
    event.value = &value;
    return vpi_register_cb(&event) != NULL;
}

static PLI_INT32 inspect_frame(PLI_BYTE8 *unused)
{
    (void)unused;
    frame_values(vpi_handle(vpiFrame, NULL), "body");
    return 0;
}

static void install(void)
{
    register_probe("$inspect_start_frame", inspect_frame);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
