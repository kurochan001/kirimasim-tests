#include <vpi_user.h>

enum {
    VIEWPORT_READ = 1,
    VIEWPORT_WRITE = 2,
    VIEWPORT_DENIED = -1,
    VIEWPORT_MISSING = -2
};

/* The qualification runner supplies permissions after resolving the viewport
 * entry against the selected envelope and access policy. */
static PLI_INT32 probe(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = vpi_iterate(vpiArgument, call);
    vpiHandle name_arg = vpi_scan(args);
    vpiHandle access_arg = vpi_scan(args);
    vpiHandle write_arg = vpi_scan(args);
    s_vpi_value value = {.format = vpiIntVal};

    vpi_get_value(access_arg, &value);
    int access = value.value.integer;
    vpi_get_value(write_arg, &value);
    int requested = value.value.integer;
    int operation = requested < 0 ? VIEWPORT_READ : VIEWPORT_WRITE;
    int result = VIEWPORT_DENIED;

    if (access & operation) {
        s_vpi_value name = {.format = vpiStringVal};
        vpi_get_value(name_arg, &name);
        vpiHandle target = vpi_handle_by_name(name.value.str, NULL);
        result = VIEWPORT_MISSING;
        if (target) {
            if (operation == VIEWPORT_WRITE) {
                value.value.integer = requested;
                vpi_put_value(target, &value, NULL, vpiNoDelay);
            }
            vpi_get_value(target, &value);
            result = value.value.integer;
        }
    }

    value.value.integer = result;
    vpi_put_value(call, &value, NULL, vpiNoDelay);
    vpi_free_object(args);
    return 0;
}

static void register_probe(void)
{
    s_vpi_systf_data tf = {
        .type = vpiSysFunc,
        .sysfunctype = vpiIntFunc,
        .tfname = "$viewport_probe",
        .calltf = probe
    };
    vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {register_probe, NULL};
