#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#if defined(vpiInterface) && defined(vpiInterfaceArray) && defined(vpiProgram)
static int same(vpiHandle first, vpiHandle second)
{
    return first != NULL && second != NULL && vpi_compare_objects(first, second);
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call != NULL ? vpi_handle(vpiScope, call) : NULL;
    vpiHandle args = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle selection = args != NULL ? vpi_scan(args) : NULL;
    if (scope == NULL || selection == NULL) {
        if (selection != NULL)
            vpi_release_handle(args);
        vpi_printf("program port probe inputs unavailable\n");
        return 0;
    }
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(selection, &value);
    vpi_release_handle(args);
    const int is_array = value.value.integer != 0;
    const PLI_INT32 interface_type = is_array ? vpiInterfaceArray : vpiInterface;
    vpiHandle module = vpi_handle(vpiInstance, scope);
    vpiHandle physical = module != NULL ? vpi_handle_by_name(
        (PLI_BYTE8 *)(is_array ? "physical[0]" : "physical"), module) : NULL;
    vpiHandle physical_owner = physical != NULL ? vpi_handle(vpiInstance, physical) : NULL;
    vpiHandle iterator = vpi_get(vpiType, scope) == vpiProgram ? vpi_iterate(interface_type, scope) : NULL;
    vpiHandle item;
    int interfaces = 0, program_owner = 0;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        if (vpi_get(vpiType, item) != interface_type)
            continue;
        ++interfaces;
        program_owner += same(scope, vpi_handle(vpiInstance, item));
    }
    vpi_printf("associated interface objects=%d with program owner=%d\n", interfaces, program_owner);
    vpi_printf("physical interface has module owner=%d\n", same(module, physical_owner));
    return 0;
}
#else
static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("program or interface declarations unavailable\n");
    return 0;
}
#endif

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_program_interface_ports";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
