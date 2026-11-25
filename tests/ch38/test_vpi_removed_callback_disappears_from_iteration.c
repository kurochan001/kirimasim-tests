/* Observe callback removal via newly obtained handles and callback delivery. */
#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

struct subscription {
    int calls;
};

static struct subscription removed;
static struct subscription kept;
static s_vpi_time delay_time = {.type = vpiSimTime, .low = 6};
static s_vpi_time no_time = {.type = vpiSuppressTime};
static s_vpi_value no_value = {.format = vpiSuppressVal};

static PLI_INT32 notified(p_cb_data callback)
{
    struct subscription *subscription = (struct subscription *)callback->user_data;
    ++subscription->calls;
    return 0;
}

static vpiHandle subscribe(PLI_INT32 reason, vpiHandle object, struct subscription *subscription)
{
    s_cb_data descriptor = {0};
    descriptor.reason = reason;
    descriptor.cb_rtn = notified;
    descriptor.obj = object;
    descriptor.time = reason == cbAfterDelay ? &delay_time : &no_time;
    descriptor.value = &no_value;
    descriptor.user_data = (PLI_BYTE8 *)subscription;
    return vpi_register_cb(&descriptor);
}

static int callback_count(void)
{
    vpiHandle iterator = vpi_iterate(vpiCallback, NULL);
    int count = 0;
    while (iterator != NULL && vpi_scan(iterator) != NULL)
        ++count;
    return count;
}

static void observe_removal(PLI_INT32 reason, vpiHandle object)
{
    int baseline = callback_count();
    vpiHandle to_remove = subscribe(reason, object, &removed);
    vpiHandle to_keep = subscribe(reason, object, &kept);
    vpi_printf("registered=%d%d\n", to_remove != NULL, to_keep != NULL);
    vpi_printf("before added=%d\n", callback_count() - baseline);
    int result = to_remove != NULL && vpi_remove_cb(to_remove);
    vpi_printf("remove result=%d\n", result);
    vpi_printf("after added=%d\n", callback_count() - baseline);
}

static PLI_INT32 value_change(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call == NULL ? NULL : vpi_iterate(vpiArgument, call);
    vpiHandle watched = iterator == NULL ? NULL : vpi_scan(iterator);
    if (watched == NULL) {
        vpi_printf("missing signal argument\n");
        return 0;
    }
    vpi_release_handle(iterator);
    observe_removal(cbValueChange, watched);
    return 0;
}

static PLI_INT32 after_delay(PLI_BYTE8 *unused)
{
    (void)unused;
    observe_removal(cbAfterDelay, NULL);
    return 0;
}

static PLI_INT32 report_calls(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("delivered removed=%d kept=%d\n", removed.calls, kept.calls);
    return 0;
}

static void task(const char *name, PLI_INT32 (*call)(PLI_BYTE8 *))
{
    s_vpi_systf_data descriptor = {0};
    descriptor.type = vpiSysTask;
    descriptor.tfname = (PLI_BYTE8 *)name;
    descriptor.calltf = call;
    vpi_register_systf(&descriptor);
}

static void install(void)
{
    task("$vt_remove_value_change", value_change);
    task("$vt_remove_after_delay", after_delay);
    task("$vt_report_callback_calls", report_calls);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
