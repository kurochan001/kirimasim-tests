#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle procedure_frame;

static PLI_INT32 inspect_procedure(PLI_BYTE8 *unused)
{
    (void)unused;
    procedure_frame = vpi_handle(vpiFrame, 0);
    vpiHandle parent = procedure_frame ? vpi_handle(vpiParent, procedure_frame) : 0;
    int frame = procedure_frame && vpi_get(vpiType, procedure_frame) == vpiFrame;
    vpi_printf("procedure frame=%d parent=%d\n", frame, parent != 0);
    return 0;
}

static PLI_INT32 inspect_task(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle task_frame = vpi_handle(vpiFrame, 0);
    vpiHandle parent = task_frame ? vpi_handle(vpiParent, task_frame) : 0;
    int same_parent = parent && procedure_frame && vpi_compare_objects(parent, procedure_frame);
    int distinct = task_frame && procedure_frame && !vpi_compare_objects(task_frame, procedure_frame);
    int value = -1;

    vpiHandle iterator = task_frame ? vpi_iterate(vpiAutomatics, task_frame) : 0;
    vpiHandle variable;
    while (iterator && (variable = vpi_scan(iterator))) {
        const char *name = vpi_get_str(vpiName, variable);
        if (name && !strcmp(name, "task_value")) {
            s_vpi_value observed = {0};
            observed.format = vpiIntVal;
            vpi_get_value(variable, &observed);
            value = (int)observed.value.integer;
        }
    }
    vpi_printf("task frame distinct=%d procedure parent=%d local=%d\n", distinct, same_parent, value);
    procedure_frame = 0;
    return 0;
}

static void startup(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_procedure_frame_version";
    task.calltf = inspect_procedure;
    vpi_register_systf(&task);
    task.tfname = (PLI_BYTE8 *)"$vt_task_frame_version";
    task.calltf = inspect_task;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {startup, 0};

#ifdef __cplusplus
}
#endif
