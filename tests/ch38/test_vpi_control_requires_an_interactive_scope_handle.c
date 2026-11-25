#include <stddef.h>
#include "checkpoint_fixtures/action_callback.h"

#define TOP "test_vpi_control_requires_an_interactive_scope_handle"

#ifdef __cplusplus
extern "C" {
#endif

static void try_target(const char *label, const char *path, PLI_INT32 expected_type)
{
    vpiHandle selected = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    const int matches_type = selected != NULL && vpi_get(vpiType, selected) == expected_type;
    vpi_printf("begin %s handle=%d type=%d\n", label, selected != NULL, matches_type);
    if (matches_type) {
        const int accepted = vpi_control(vpiSetInteractiveScope, selected);
        const int error = vpi_chk_error(NULL) != 0;
        vpi_printf("end %s accepted=%d error=%d\n", label, accepted, error);
    }
}

static PLI_INT32 check_interactive_scope(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    if (call == NULL)
        return 0;
    vpiHandle arguments = vpi_iterate(vpiArgument, call);
    vpiHandle argument = arguments ? vpi_scan(arguments) : NULL;
    if (argument == NULL)
        return 0;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(argument, &value);
    vpi_release_handle(arguments);
    switch (value.value.integer) {
    case 0:
        try_target("first", TOP ".first", vpiModule);
        break;
    case 1:
        try_target("variable", TOP ".first.marker", vpiReg);
        break;
    case 2:
        try_target("second", TOP ".second", vpiModule);
        break;
    }
    return 0;
}

static void install(void)
{
    register_probe("$check_interactive_scope", check_interactive_scope);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
