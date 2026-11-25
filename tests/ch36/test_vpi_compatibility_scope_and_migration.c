#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define STRINGIFY_RAW(value) #value
#define STRINGIFY(value) STRINGIFY_RAW(value)
#define FULL_TOP "test_vpi_compatibility_scope_and_migration"
#define COMPATIBLE_TOP "vpi_mode_compatible_top"

static PLI_INT32 observe(p_cb_data unused)
{
    (void)unused;
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)FULL_TOP, 0);
    vpiHandle scalar = vpi_handle_by_name(
        (PLI_BYTE8 *)(top ? FULL_TOP ".legacy.scalar" : COMPATIBLE_TOP ".legacy.scalar"), 0);
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    if (scalar)
        vpi_get_value(scalar, &value);
    vpi_printf("abi=%s scalar=%d value=%d\n", STRINGIFY(vpi_get), scalar != 0, (int)value.value.integer);

    if (!top)
        return 0;

    vpi_printf("modern partition queried\n");
    vpiHandle element = vpi_handle_by_name((PLI_BYTE8 *)FULL_TOP ".modern.element", 0);
    vpi_printf("class handle=%d class variable=%d\n", element != 0,
               element && vpi_get(vpiType, element) == vpiClassVar);

    vpiHandle readings = vpi_handle_by_name((PLI_BYTE8 *)FULL_TOP ".modern.readings", 0);
    vpiHandle item = readings ? vpi_handle_by_index(readings, 1) : 0;
    s_vpi_value real_value = {0};
    real_value.format = vpiRealVal;
    if (item)
        vpi_get_value(item, &real_value);
    int kind = readings ? (int)vpi_get(vpiType, readings) : -1;
#ifdef VPI_LEGACY_REAL_ADAPTER
    int migrated_kind = kind == vpiRealVar;
#else
    int migrated_kind = kind == vpiArrayVar;
#endif
    vpi_printf("real root=%d legacy real=%d current array=%d selected view=%d item=%d value=%.2f\n",
               readings != 0, kind == vpiRealVar, kind == vpiArrayVar, migrated_kind,
               item != 0, real_value.value.real);
    return 0;
}

static void register_test(void)
{
    s_cb_data end = {0};
    end.reason = cbEndOfSimulation;
    end.cb_rtn = observe;
    vpi_register_cb(&end);
}

void (*vlog_startup_routines[])(void) = {register_test, 0};

#ifdef __cplusplus
}
#endif
