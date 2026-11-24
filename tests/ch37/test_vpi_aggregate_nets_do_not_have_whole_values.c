#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_aggregate_nets_do_not_have_whole_values"

static vpiHandle named(const char *path)
{
    return vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
}

static unsigned unavailable(vpiHandle h)
{
    const PLI_INT32 marker = -185309457;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    value.value.integer = marker;
    vpi_get_value(h, &value);
    s_vpi_error_info error = {0};
    return vpi_chk_error(&error) >= vpiWarning || value.format == vpiSuppressVal ||
           (value.format == vpiIntVal && value.value.integer == marker);
}

static void report(const char *label, vpiHandle h, PLI_INT32 expected)
{
    if (h == NULL) {
        vpi_printf("%s: missing object\n", label);
        return;
    }
    unsigned kind = vpi_get(vpiType, h) == expected;
    vpi_printf("%s kind=%u unavailable=%u\n", label, kind, unavailable(h));
}

static unsigned scalar_value(vpiHandle h)
{
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    value.value.integer = -1;
    if (h != NULL)
        vpi_get_value(h, &value);
    return value.format == vpiIntVal ? (unsigned)value.value.integer : (unsigned)-1;
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle bank = named(TOP ".bank");
    report("array net", bank, vpiNetArray);
    report("structure net", named(TOP ".record_bus"), vpiStructNet);
    report("union net", named(TOP ".choice_bus"), vpiUnionNet);
    report("interconnect array", named(TOP ".routes"), vpiInterconnectArray);

    vpiHandle second = bank != NULL ? vpi_handle_by_index(bank, 1) : NULL;
    unsigned ordinary = scalar_value(named(TOP ".ordinary"));
    unsigned element = scalar_value(second);
    vpi_printf("ordinary net=%02x array element=%02x\n", ordinary, element);
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = "$vt_probe_whole_nets";
    definition.calltf = inspect;
    vpi_register_systf(&definition);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
