#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef GHOST_HANDLE_PROBE
#include <dlfcn.h>
#endif

#define TOP "test_vpi_frame_and_thread_handle_release"

enum { FRAME, THREAD, STAMP, VECTOR, BIT, FRAME_CALLBACK, THREAD_CALLBACK, HANDLE_COUNT };
enum { BRANCH_COUNT = 2 };

struct branch {
    int index;
    vpiHandle handles[HANDLE_COUNT];
};

static struct branch branches[BRANCH_COUNT] = {{.index = 0}, {.index = 1}};
static vpiHandle persistent;
static s_vpi_time callback_time = {.type = vpiSimTime};
static s_vpi_value callback_value = {.format = vpiSuppressVal};

static int int_value(vpiHandle item)
{
    s_vpi_value value = {.format = vpiIntVal};
    if (!item)
        return -1;
    vpi_get_value(item, &value);
    return value.value.integer;
}

static int argument(void)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle arguments = call ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle argument = arguments ? vpi_scan(arguments) : NULL;
    int result = int_value(argument);
    if (argument)
        vpi_free_object(arguments);
    return result;
}

static PLI_INT32 ended(p_cb_data event)
{
    const struct branch *branch = (const struct branch *)event->user_data;
    const int frame_end = event->reason == cbEndOfFrame;
    const vpiHandle expected = branch->handles[frame_end ? FRAME : THREAD];
    int same = expected && event->obj && vpi_compare_objects(expected, event->obj);
    int time = event->time && event->time->high == 0 ? (int)event->time->low : -1;
    if (frame_end)
        vpi_printf("frame %d end at %d identity=%d stamp=%d\n", branch->index, time, same,
                   int_value(branch->handles[STAMP]));
    else
        vpi_printf("thread %d end at %d identity=%d\n", branch->index, time, same);
    return 0;
}

static vpiHandle subscribe(int reason, vpiHandle object, struct branch *branch)
{
    if (!object)
        return NULL;
    s_cb_data request = {
        .reason = reason, .obj = object, .cb_rtn = ended, .time = &callback_time,
        .value = &callback_value, .user_data = (PLI_BYTE8 *)branch,
    };
    return vpi_register_cb(&request);
}

static int registered(vpiHandle callback, int reason, vpiHandle object, const struct branch *branch)
{
    s_cb_data info = {0};
    if (callback)
        vpi_get_cb_info(callback, &info);
    return info.reason == reason && info.cb_rtn == ended && info.user_data == (const PLI_BYTE8 *)branch
        && object && info.obj && vpi_compare_objects(object, info.obj);
}

static PLI_INT32 arm(PLI_BYTE8 *unused)
{
    (void)unused;
    int index = argument();
    if (index < 0 || index >= BRANCH_COUNT) {
        vpi_printf("invalid activation index\n");
        return 0;
    }
    struct branch *branch = &branches[index];
    vpiHandle *handle = branch->handles;
    handle[FRAME] = vpi_handle(vpiFrame, NULL);
    handle[THREAD] = handle[FRAME] ? vpi_handle(vpiThread, handle[FRAME]) : NULL;
    vpiHandle automatics = handle[FRAME] ? vpi_iterate(vpiAutomatics, handle[FRAME]) : NULL;
    vpiHandle member;
    while (automatics && (member = vpi_scan(automatics))) {
        const char *name = vpi_get_str(vpiName, member);
        if (name && strcmp(name, "stamp") == 0)
            handle[STAMP] = member;
        if (name && strcmp(name, "bits") == 0)
            handle[VECTOR] = member;
    }
    handle[BIT] = handle[VECTOR] ? vpi_handle_by_index(handle[VECTOR], 1) : NULL;
    handle[FRAME_CALLBACK] = subscribe(cbEndOfFrame, handle[FRAME], branch);
    handle[THREAD_CALLBACK] = subscribe(cbEndOfThread, handle[THREAD], branch);
    if (!persistent)
        persistent = vpi_handle_by_name(TOP ".module_state", NULL);
    vpi_printf("arm %d frame=%d thread=%d automatic=%d vector=%d bit=%d callbacks=%d/%d\n",
               index, handle[FRAME] && vpi_get(vpiType, handle[FRAME]) == vpiFrame,
               handle[THREAD] && vpi_get(vpiType, handle[THREAD]) == vpiThread,
               int_value(handle[STAMP]), handle[VECTOR] && vpi_get(vpiAutomatic, handle[VECTOR]) == 1,
               handle[BIT] && vpi_get(vpiIndex, handle[BIT]) == 1,
               registered(handle[FRAME_CALLBACK], cbEndOfFrame, handle[FRAME], branch),
               registered(handle[THREAD_CALLBACK], cbEndOfThread, handle[THREAD], branch));
    return 0;
}

#ifdef GHOST_HANDLE_PROBE
/* The debugger captures the callback manager on a live vpi_get_cb_info call. */
static void *callback_manager;

__attribute__((visibility("default"))) int remember_release_manager(void *manager)
{
    callback_manager = manager;
    return manager != NULL;
}

static void inspect_handle_tables(int phase)
{
    void *(*instance)(void) = dlsym(RTLD_DEFAULT, "_ZN9sukimasim3vpi12VPIInterface11getInstanceEv");
    void *(*lookup)(void *, vpiHandle) = dlsym(RTLD_DEFAULT, "_ZN9sukimasim3vpi12VPIInterface13getHandleImplEPj");
    void *(*callback)(void *, vpiHandle) = dlsym(RTLD_DEFAULT, "_ZN9sukimasim3vpi18VPICallbackManager15getCallbackInfoEPj");
    _Bool (*thread_live)(vpiHandle) = dlsym(RTLD_DEFAULT, "_ZN9sukimasim3vpi19runtimeThreadIsLiveEPj");
    if (!instance || !lookup || !callback || !callback_manager || !thread_live) {
        puts("RELEASE inspector unavailable");
        return;
    }
    void *interface = instance();
    printf("RELEASE phase=%d persistent=%d\n", phase, lookup(interface, persistent) != NULL);
    for (int index = 0; index < BRANCH_COUNT; ++index) {
        vpiHandle *handle = branches[index].handles;
        printf("RELEASE branch=%d table=", index);
        for (int entry = 0; entry < HANDLE_COUNT; ++entry)
            printf("%d", handle[entry] && lookup(interface, handle[entry]) != NULL);
        printf(" manager=%d%d thread-live=%d\n",
               handle[FRAME_CALLBACK] && callback(callback_manager, handle[FRAME_CALLBACK]) != NULL,
               handle[THREAD_CALLBACK] && callback(callback_manager, handle[THREAD_CALLBACK]) != NULL,
               handle[THREAD] && lookup(interface, handle[THREAD]) && thread_live(handle[THREAD]));
    }
    fflush(stdout);
}
#endif

static PLI_INT32 sample(PLI_BYTE8 *unused)
{
    (void)unused;
    int phase = argument();
    if (phase == 1) {
        vpiHandle *first = branches[0].handles;
        vpiHandle *second = branches[1].handles;
        vpi_printf("distinct frame=%d thread=%d\n",
                   first[FRAME] && second[FRAME] && !vpi_compare_objects(first[FRAME], second[FRAME]),
                   first[THREAD] && second[THREAD] && !vpi_compare_objects(first[THREAD], second[THREAD]));
    }
    vpi_printf("sample %d module-state=%d\n", phase, int_value(persistent));
#ifdef GHOST_HANDLE_PROBE
    inspect_handle_tables(phase);
#endif
    return 0;
}

static void install(void)
{
    s_vpi_systf_data record = {
        .type = vpiSysTask, .tfname = "$record_runtime_handles", .calltf = arm,
    };
    s_vpi_systf_data inspect = {
        .type = vpiSysTask, .tfname = "$sample_runtime_handles", .calltf = sample,
    };
    vpi_register_systf(&record);
    vpi_register_systf(&inspect);
}

void (*vlog_startup_routines[])(void) = {install, NULL};
