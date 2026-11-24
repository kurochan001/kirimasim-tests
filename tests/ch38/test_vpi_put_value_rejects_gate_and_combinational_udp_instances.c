/* Compare vpiNoDelay writes to primitive handles with a variable control. */
#include <stddef.h>
#include <stdio.h>
#include "vpi_user.h"

#define TOP "test_vpi_put_value_rejects_gate_and_combinational_udp_instances"

static int put(const char *name, PLI_INT32 primitive_type, const char *label)
{
    vpiHandle object = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    if (!object || (primitive_type && vpi_get(vpiType, object) != primitive_type)) {
        vpi_printf("wrong object for %s\n", name);
        return -1;
    }
    s_vpi_value value = {.format = vpiScalarVal, .value.scalar = vpi1};
    vpi_put_value(object, &value, NULL, vpiNoDelay);
    s_vpi_error_info error = {0};
    int failed = vpi_chk_error(&error) >= vpiError;
    if (failed && error.message != NULL)
        fprintf(stderr, "%s write error: %s\n", label, (const char *)error.message);
    return failed;
}

static PLI_INT32 test_targets(PLI_BYTE8 *unused)
{
    (void)unused;
    int gate = put(TOP ".builtin", vpiGate, "gate");
    int variable = put(TOP ".control", 0, "variable");
    int udp = put(TOP ".combinational", vpiUdp, "udp");
    vpi_printf("gate error=%d udp error=%d variable error=%d\n", gate, udp, variable);
    return 0;
}

static void register_tests(void)
{
    s_vpi_systf_data task = {
        .type = vpiSysTask, .tfname = "$vt_write_primitives", .calltf = test_targets,
    };
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};
