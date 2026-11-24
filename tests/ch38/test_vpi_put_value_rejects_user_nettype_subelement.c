/* Compare whole, ordinary bit, and user-defined-nettype bit assignments. */
#include <stddef.h>
#include "vpi_user.h"

#define TOP "test_vpi_put_value_rejects_user_nettype_subelement"

static int put(vpiHandle object, int number, const char *name)
{
    if (!object) {
        vpi_printf("missing handle for %s\n", name);
        return -1;
    }
    s_vpi_value value = {.format = vpiIntVal, .value.integer = number};
    vpi_put_value(object, &value, NULL, vpiNoDelay);
    return vpi_chk_error(NULL) >= vpiError;
}

static vpiHandle indexed(const char *name, int index)
{
    vpiHandle parent = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    return parent ? vpi_handle_by_index(parent, index) : NULL;
}

static PLI_INT32 legal(PLI_BYTE8 *unused)
{
    (void)unused;
    int whole = put(vpi_handle_by_name(TOP ".typed_net", NULL), 9, "whole user net");
    int net = put(indexed(TOP ".ordinary", 1), 1, "ordinary net bit");
    int variable = put(indexed(TOP ".variable_bits", 2), 1, "variable bit");
    vpi_printf("whole net error=%d ordinary bit error=%d variable bit error=%d\n",
               whole, net, variable);
    return 0;
}

static PLI_INT32 excluded(PLI_BYTE8 *unused)
{
    (void)unused;
    int error = put(indexed(TOP ".typed_net", 2), 1, "user net bit");
    vpi_printf("typed-net bit error=%d\n", error);
    return 0;
}

static void register_tests(void)
{
    s_vpi_systf_data allowed = {
        .type = vpiSysTask, .tfname = "$vt_put_legal_targets", .calltf = legal,
    };
    s_vpi_systf_data forbidden = {
        .type = vpiSysTask, .tfname = "$vt_put_excluded_target", .calltf = excluded,
    };
    vpi_register_systf(&allowed);
    vpi_register_systf(&forbidden);
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};
