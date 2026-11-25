#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle get_only(vpiHandle source, PLI_INT32 relationship)
{
    vpiHandle iter = vpi_iterate(relationship, source);
    if (!iter)
        return NULL;
    vpiHandle result = vpi_scan(iter);
    if (!result || !vpi_scan(iter))
        return result;
    vpi_free_object(iter);
    vpi_printf("unexpected extra object for relationship %d\n", relationship);
    return NULL;
}

static PLI_INT32 old_interface(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle scope = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_deprecated_constants_and_live_frame", NULL);
    vpiHandle old = scope ? get_only(scope, vpiInterfaceDecl) : NULL;
    vpiHandle current = scope ? get_only(scope, vpiVirtualInterfaceVar) : NULL;
    const char *name = current ? vpi_get_str(vpiName, current) : NULL;
    int named = name && !strcmp(name, "selected");
    int type_ok = current && vpi_get(vpiType, current) == vpiVirtualInterfaceVar;
    int same = old && current && vpi_compare_objects(old, current);
    vpi_printf("alias=%d/%d same=%d selected=%d type=%d\n",
               vpiInterfaceDecl, vpiVirtualInterfaceVar, same, named, type_ok);
    vpi_printf("deprecated property=%d unknown value=%d\n", vpiValid, vpiValidUnknown);
    return 0;
}

static PLI_INT32 live_frame(PLI_BYTE8 *unused)
{
    (void)unused;
    /* Start from the current frame each time and keep child handles local to this call. */
    vpiHandle frame = vpi_handle(vpiFrame, NULL);
    vpiHandle parent = frame ? vpi_handle(vpiThread, frame) : NULL;
    vpiHandle child = parent ? get_only(parent, vpiThread) : NULL;
    vpiHandle child_frame = child ? vpi_handle(vpiFrame, child) : NULL;
    vpiHandle local = child_frame ? get_only(child_frame, vpiAutomatics) : NULL;
    const char *name = local ? vpi_get_str(vpiName, local) : NULL;
    int local_found = name && !strcmp(name, "local_value");
    s_vpi_value observed = {0};
    observed.format = vpiIntVal;
    if (local_found)
        vpi_get_value(local, &observed);
    vpi_printf("parent=%d child=%d frame=%d local=%d\n", parent != NULL,
               child != NULL, child_frame != NULL, local_found ? (int)observed.value.integer : -1);
    return 0;
}

static void register_tests(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_deprecated_interface";
    task.calltf = old_interface;
    vpi_register_systf(&task);
    task.tfname = (PLI_BYTE8 *)"$vt_live_child_frame";
    task.calltf = live_frame;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_tests, 0};

#ifdef __cplusplus
}
#endif
