#include <stddef.h>
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

static int callbacks;
static int correct_reason;
static vpiHandle last_scope;
static vpiHandle requested_scope;
static int accepted;
static int requests;
static const char *label;

static PLI_INT32 scope_changed(p_cb_data callback)
{
    ++callbacks;
    correct_reason = callback->reason == cbInteractiveScopeChange;
    last_scope = callback->obj;
    return 0;
}

static PLI_INT32 request(PLI_BYTE8 *unused)
{
    const char *module = "test_vpi_control_scope_change_reports_selected_instance";
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)module, NULL);
    (void)unused;
    if (top == NULL)
        return 0;
    int first = requests++ == 0;
    label = first ? "first" : "second";
    const char *name = first ? "first_child" : "second_child";
    requested_scope = vpi_handle_by_name((PLI_BYTE8 *)name, top);
    last_scope = NULL;
    correct_reason = 0;
    callbacks = 0;
    accepted = requested_scope != NULL && vpi_control(vpiSetInteractiveScope, requested_scope) == 1;
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    if (label != NULL) {
        int correct_scope = last_scope != NULL && requested_scope != NULL &&
            vpi_compare_objects(last_scope, requested_scope);
        vpi_printf("%s accepted=%d callback count=%d reason=%d new scope=%d\n",
                   label, accepted, callbacks, correct_reason, correct_scope);
    }
    return 0;
}

static void install(void)
{
    register_action(cbInteractiveScopeChange, scope_changed, NULL);
    register_probe("$request_scope_change", request);
    register_probe("$report_scope_change", report);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
