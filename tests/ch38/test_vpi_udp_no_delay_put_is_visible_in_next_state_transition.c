/* Set the current state of one sequential UDP and leave its control untouched. */
#include <stddef.h>
#include "vpi_user.h"

#define INSTANCE "test_vpi_udp_no_delay_put_is_visible_in_next_state_transition.edited"

static PLI_INT32 write_state(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle udp = vpi_handle_by_name(INSTANCE, NULL);
    if (!udp || vpi_get(vpiType, udp) != vpiUdp) {
        vpi_printf("missing UDP instance\n");
        return 0;
    }
    s_vpi_value value = {.format = vpiScalarVal, .value.scalar = vpi1};
    vpi_put_value(udp, &value, NULL, vpiNoDelay);
    if (vpi_chk_error(NULL))
        vpi_printf("could not set the UDP state\n");
    return 0;
}

static PLI_INT32 check_delay_error(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle udp = vpi_handle_by_name(INSTANCE, NULL);
    s_vpi_value unchanged = {.format = vpiScalarVal, .value.scalar = vpi0};
    s_vpi_time delay = {.type = vpiSimTime, .low = 3};
    if (!udp) {
        vpi_printf("missing UDP instance\n");
        return 0;
    }
    vpi_put_value(udp, &unchanged, &delay, vpiPureTransportDelay);
    vpi_printf("pure-transport is an error=%d\n", vpi_chk_error(NULL) >= vpiError);
    return 0;
}

static void register_tests(void)
{
    s_vpi_systf_data write_task = {
        .type = vpiSysTask, .tfname = "$vt_write_udp_state", .calltf = write_state,
    };
    s_vpi_systf_data error_task = {
        .type = vpiSysTask, .tfname = "$vt_require_no_delay_udp", .calltf = check_delay_error,
    };
    vpi_register_systf(&write_task);
    vpi_register_systf(&error_task);
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};
