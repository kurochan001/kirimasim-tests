#include "sv_vpi_user.h"

#ifdef FRAME_TABLE_OBSERVATION
#include <dlfcn.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle cached_child;
static int end_count;

#ifdef FRAME_TABLE_OBSERVATION
/* An opaque key for the native map lookup. Never pass it to the public VPI. */
static vpiHandle direct_key, traversal_key;

static void observe_table(const char *phase)
{
    void *(*instance)(void) = dlsym(RTLD_DEFAULT, "_ZN9sukimasim3vpi12VPIInterface11getInstanceEv");
    void *(*lookup)(void *, vpiHandle) = dlsym(RTLD_DEFAULT, "_ZN9sukimasim3vpi12VPIInterface13getHandleImplEPj");
    int (*property)(const void *, int, int) = dlsym(RTLD_DEFAULT, "_ZNK9sukimasim3vpi13VPIHandleImpl11getPropertyEii");
    if (!instance || !lookup || !property || !direct_key || !traversal_key) {
        vpi_printf("native table %s unavailable\n", phase);
        return;
    }
    void *table = instance();
    void *direct = lookup(table, direct_key);
    void *traversed = lookup(table, traversal_key);
    int direct_active = direct ? property(direct, vpiActive, -1) : -1;
    int traversed_active = traversed ? property(traversed, vpiActive, -1) : -1;
    vpi_printf("native table %s direct=%d/%d traversed=%d/%d\n",
               phase, direct != 0, direct_active, traversed != 0, traversed_active);
}
#endif

static vpiHandle current_child(void)
{
    vpiHandle frame = vpi_handle(vpiFrame, 0);
    vpiHandle parent = frame ? vpi_handle(vpiThread, frame) : 0;
    vpiHandle iterator = parent ? vpi_iterate(vpiThread, parent) : 0;
    vpiHandle thread = iterator ? vpi_scan(iterator) : 0;
    if (thread && vpi_scan(iterator)) {
        vpi_free_object(iterator);
        return 0;
    }
    return thread ? vpi_handle(vpiFrame, thread) : 0;
}

static PLI_INT32 on_end(p_cb_data event)
{
    int same = event->obj && cached_child && vpi_compare_objects(event->obj, cached_child);
    if (event->reason == cbEndOfFrame && same) {
        end_count++;
        cached_child = 0;
    }
    vpi_printf("end callback same frame=%d count=%d\n", same, end_count);
    return 0;
}

static PLI_INT32 arm(PLI_BYTE8 *data)
{
    (void)data;
    cached_child = vpi_handle(vpiFrame, 0);
    int type_ok = cached_child && vpi_get(vpiType, cached_child) == vpiFrame;
    s_cb_data callback = {0};
    callback.reason = cbEndOfFrame;
    callback.obj = cached_child;
    callback.cb_rtn = on_end;
    int registered = cached_child && vpi_register_cb(&callback) != 0;
    vpi_printf("child frame=%d callback=%d\n", type_ok, registered);
#ifdef FRAME_TABLE_OBSERVATION
    int old_property = cached_child ? (int)vpi_get(vpiValid, cached_child) : 0;
    vpi_printf("obsolete query value=%d undefined=%d\n", old_property, old_property == vpiUndefined);
    direct_key = cached_child;
#endif
    return 0;
}

static PLI_INT32 sample(PLI_BYTE8 *data)
{
    (void)data;
    vpiHandle child = current_child();
    vpi_printf("traversal frame=%d\n", child && vpi_get(vpiType, child) == vpiFrame);
#ifdef FRAME_TABLE_OBSERVATION
    traversal_key = child;
    observe_table("live");
#endif
    return 0;
}

static PLI_INT32 after(PLI_BYTE8 *data)
{
    (void)data;
#ifdef FRAME_TABLE_OBSERVATION
    observe_table("after end");
#endif
    vpi_printf("after end cached=%d child=%d callbacks=%d\n",
               cached_child != 0, current_child() != 0, end_count);
    return 0;
}

static void register_tasks(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_arm_frame_watch";
    task.calltf = arm;
    vpi_register_systf(&task);
    task.tfname = (PLI_BYTE8 *)"$vt_sample_frame_watch";
    task.calltf = sample;
    vpi_register_systf(&task);
    task.tfname = (PLI_BYTE8 *)"$vt_check_frame_watch";
    task.calltf = after;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_tasks, 0};

#ifdef __cplusplus
}
#endif
