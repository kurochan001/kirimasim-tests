#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void show(const char *label, vpiHandle event_handle)
{
    int named_event = event_handle != NULL && vpi_get(vpiType, event_handle) == vpiNamedEvent;
    int is_member = event_handle != NULL ? (int)vpi_get(vpiArray, event_handle) : -1;
    vpi_printf("%s named event=%d legacy array=%d\n", label, named_event, is_member);
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle scope = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_legacy_array_property_on_named_event_elements", NULL);
    (void)unused;
    if (scope != NULL) {
        vpiHandle single = vpi_handle_by_name((PLI_BYTE8 *)"standalone", scope);
        vpiHandle array = vpi_handle_by_name((PLI_BYTE8 *)"events", scope);
        show("standalone", single);
        show("array element", array != NULL ? vpi_handle_by_index(array, -1) : NULL);
    }
    return 0;
}

static void register_probe(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$probe_array_events";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_probe, NULL};

#ifdef __cplusplus
}
#endif
