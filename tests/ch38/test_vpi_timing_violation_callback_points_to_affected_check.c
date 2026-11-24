#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

enum { CAPACITY = 4 };

struct violation {
    unsigned tick;
    int timing_object;
    int reason_matches;
    int same_object;
    const char *kind;
};

static vpiHandle setup_check, hold_check;
static struct violation violations[CAPACITY];
static int total;

static PLI_INT32 on_violation(p_cb_data data)
{
    if (total < CAPACITY) {
        struct violation *event = &violations[total];
        s_vpi_time time_now = {0};
        vpiHandle object = data->obj;
        int type = object != NULL ? vpi_get(vpiTchkType, object) : 0;
        vpiHandle expected = NULL;
        if (type == vpiSetup) {
            event->kind = "setup";
            expected = setup_check;
        } else if (type == vpiHold) {
            event->kind = "hold";
            expected = hold_check;
        } else {
            event->kind = "unknown";
        }
        time_now.type = vpiSimTime;
        vpi_get_time(NULL, &time_now);
        event->tick = time_now.low;
        event->timing_object = object != NULL && vpi_get(vpiType, object) == vpiTchk;
        event->reason_matches = data->reason == cbTchkViolation;
        event->same_object = expected != NULL && vpi_compare_objects(object, expected);
    }
    ++total;
    return 0;
}

static PLI_INT32 start(PLI_BYTE8 *unused)
{
    const char *path = "test_vpi_timing_violation_callback_points_to_affected_check.dut";
    vpiHandle owner = vpi_handle_by_name((PLI_BYTE8 *)path, NULL), object;
    vpiHandle iter = owner != NULL ? vpi_iterate(vpiTchk, owner) : NULL;
    s_cb_data registration = {0};
    (void)unused;
    while (iter != NULL && (object = vpi_scan(iter)) != NULL) {
        int group = vpi_get(vpiTchkType, object);
        if (group == vpiSetup)
            setup_check = object;
        if (group == vpiHold)
            hold_check = object;
    }
    registration.reason = cbTchkViolation;
    registration.cb_rtn = on_violation;
    vpi_printf("checks=%d/%d registered=%d\n", setup_check != NULL, hold_check != NULL,
               vpi_register_cb(&registration) != NULL);
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("violations=%d\n", total);
    for (int i = 0; i < total && i < CAPACITY; ++i) {
        struct violation *event = &violations[i];
        vpi_printf("t=%u kind=%s check=%d reason=%d same=%d\n", event->tick, event->kind,
                   event->timing_object, event->reason_matches, event->same_object);
    }
    return 0;
}

static void register_tasks(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$watch_timing_violations";
    task.calltf = start;
    vpi_register_systf(&task);
    task.tfname = (PLI_BYTE8 *)"$report_timing_violations";
    task.calltf = report;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_tasks, NULL};

#ifdef __cplusplus
}
#endif
