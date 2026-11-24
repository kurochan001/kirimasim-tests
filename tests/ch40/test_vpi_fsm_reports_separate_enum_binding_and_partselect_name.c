#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_fsm_reports_separate_enum_binding_and_partselect_name"

static int int_value(vpiHandle handle)
{
    if (handle == NULL) return -1;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    value.value.integer = -1;
    vpi_get_value(handle, &value);
    return (int)value.value.integer;
}

static void report_fsm(const char *name, vpiHandle fsm, PLI_INT32 expression_type)
{
    vpiHandle expression = fsm != NULL ? vpi_handle(vpiFsmStateExpression, fsm) : NULL;
    vpiHandle iterator = fsm != NULL ? vpi_iterate(vpiFsmStates, fsm) : NULL;
    vpiHandle state;
    uint32_t mask = 0;
    int count = 0;
    while (iterator != NULL && (state = vpi_scan(iterator)) != NULL) {
        int code = int_value(state);
        if (code >= 0 && code < 32) mask |= UINT32_C(1) << (unsigned)code;
        ++count;
    }
    vpi_printf("%s: expression=%d width=%d value=%d states=%d codes=%03x maximum=%d\n",
               name, expression != NULL && vpi_get(vpiType, expression) == expression_type,
               expression != NULL ? (int)vpi_get(vpiSize, expression) : -1,
               int_value(expression), count, (unsigned)mask,
               fsm != NULL ? (int)vpi_get(vpiCoveredMax, fsm) : -1);
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle top = vpi_handle_by_name(TOP, NULL);
    vpiHandle iterator = top != NULL ? vpi_iterate(vpiFsm, top) : NULL;
    vpiHandle whole = NULL, slice = NULL, fsm;
    int count = 0;
    while (iterator != NULL && (fsm = vpi_scan(iterator)) != NULL) {
        const char *name = vpi_get_str(vpiName, fsm);
        if (name != NULL && strcmp(name, "cfg_state") == 0) whole = fsm;
        if (name != NULL && strcmp(name, "frame_rx") == 0) slice = fsm;
        ++count;
    }
    vpi_printf("FSMs=%d\n", count);
    report_fsm("cfg_state", whole, vpiReg);
    report_fsm("frame_rx", slice, vpiPartSelect);
    return 0;
}

static void register_test(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = "$vt_fsm_bindings";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_test, NULL};

#ifdef __cplusplus
}
#endif
