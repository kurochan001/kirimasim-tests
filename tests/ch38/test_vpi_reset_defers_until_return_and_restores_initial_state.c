#define RESET_TEST_TOP "test_vpi_reset_defers_until_return_and_restores_initial_state"
#include "checkpoint_fixtures/reset_trace.h"

#ifdef __cplusplus
extern "C" {
#endif

static int before_reset;
static int after_reset;
static int requested;

static PLI_INT32 request(PLI_BYTE8 *unused)
{
    (void)unused;
    if (requested)
        return 0;
    requested = 1;
    int accepted = vpi_control(vpiReset, 1, 73, 0);
    report_reset_state(accepted == 1 ? "request accepted=1" : "request accepted=0");
    return 0;
}

static PLI_INT32 probe_userdata(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle arguments = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle stage = arguments != NULL ? vpi_scan(arguments) : NULL;
    s_vpi_value value = {0};
    (void)unused;
    if (stage == NULL)
        return 0;
    vpi_release_handle(arguments);
    value.format = vpiIntVal;
    vpi_get_value(stage, &value);
    switch (value.value.integer) {
    case 0: {
        int wrote = vpi_put_userdata(call, &before_reset);
        vpi_printf("initial userdata set=%d\n", wrote == 1 && vpi_get_userdata(call) == &before_reset);
        break;
    }
    case 1:
        vpi_printf("before reset same userdata=%d\n", vpi_get_userdata(call) == &before_reset);
        break;
    case 2: {
        int cleared = vpi_get_userdata(call) == NULL;
        int wrote = vpi_put_userdata(call, &after_reset);
        vpi_printf("reset userdata cleared=%d restored=%d\n",
                   cleared, wrote == 1 && vpi_get_userdata(call) == &after_reset);
        break;
    }
    case 3:
        vpi_printf("later reset userdata matches=%d\n", vpi_get_userdata(call) == &after_reset);
        break;
    }
    return 0;
}

static void install(void)
{
    trace_reset();
    register_probe("$request_vpi_reset", request);
    register_probe("$probe_reset_userdata", probe_userdata);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
