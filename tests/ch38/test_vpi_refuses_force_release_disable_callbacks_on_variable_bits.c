/* Refuse callbacks on a variable bit, with separate legal targets as controls. */
#include <stddef.h>
#include "vpi_user.h"

#define TOP "test_vpi_refuses_force_release_disable_callbacks_on_variable_bits"

static struct {
    int net_force, net_release, var_force, var_release, block_disable;
    int invalid_firings;
    int force_refused, release_refused, disable_refused;
} observed;

static s_vpi_time suppress_time = {.type = vpiSuppressTime};
static s_vpi_value suppress_value = {.format = vpiSuppressVal};

static PLI_INT32 count(p_cb_data data)
{
    int *record = (int *)data->user_data;
    ++*record;
    return 0;
}

static vpiHandle subscribe(PLI_INT32 reason, vpiHandle target, int *deliveries)
{
    s_cb_data callback = {
        .reason = reason,
        .cb_rtn = count,
        .obj = target,
        .time = &suppress_time,
        .value = &suppress_value,
        .user_data = (PLI_BYTE8 *)deliveries,
    };
    return target ? vpi_register_cb(&callback) : NULL;
}

static int refused(PLI_INT32 reason, vpiHandle target)
{
    vpiHandle registered = subscribe(reason, target, &observed.invalid_firings);
    return !registered && vpi_chk_error(NULL) >= vpiError;
}

static PLI_INT32 setup(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle net = vpi_handle_by_name(TOP ".regular", NULL);
    vpiHandle var = vpi_handle_by_name(TOP ".variable_bits", NULL);
    vpiHandle block = vpi_handle_by_name(TOP ".watched_begin", NULL);
    vpiHandle net_bit = net ? vpi_handle_by_index(net, 1) : NULL;
    vpiHandle var_bit = var ? vpi_handle_by_index(var, 1) : NULL;

    if (!net_bit || !var_bit || !block) {
        vpi_printf("missing net bit, variable bit, or named block\n");
        return 0;
    }
    observed.force_refused = refused(cbForce, var_bit);
    observed.release_refused = refused(cbRelease, var_bit);
    observed.disable_refused = refused(cbDisable, var_bit);

    if (!subscribe(cbForce, net_bit, &observed.net_force) ||
        !subscribe(cbRelease, net_bit, &observed.net_release) ||
        !subscribe(cbForce, var, &observed.var_force) ||
        !subscribe(cbRelease, var, &observed.var_release) ||
        !subscribe(cbDisable, block, &observed.block_disable))
        vpi_printf("could not register a control target\n");
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("refused force=%d release=%d disable=%d\n",
               observed.force_refused, observed.release_refused, observed.disable_refused);
    vpi_printf("controls net-force=%d net-release=%d variable-force=%d variable-release=%d block-disable=%d\n",
               observed.net_force, observed.net_release, observed.var_force, observed.var_release,
               observed.block_disable);
    vpi_printf("invalid-callback deliveries=%d\n", observed.invalid_firings);
    return 0;
}

static void register_tests(void)
{
    s_vpi_systf_data setup_task = {
        .type = vpiSysTask, .tfname = "$vt_select_callback_setup", .calltf = setup,
    };
    s_vpi_systf_data report_task = {
        .type = vpiSysTask, .tfname = "$vt_select_callback_report", .calltf = report,
    };
    vpi_register_systf(&setup_task);
    vpi_register_systf(&report_task);
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};
