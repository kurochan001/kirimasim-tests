#define VPI_COMPATIBILITY_VERSION_1364v2005 1
#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int property(PLI_INT32 key, vpiHandle handle)
{
    return handle != NULL ? vpi_get(key, handle) : -1;
}

static void report(vpiHandle top, const char *label, const char *single_name,
                   const char *array_name, PLI_INT32 kind)
{
    vpiHandle single = vpi_handle_by_name((PLI_BYTE8 *)single_name, top);
    vpiHandle array = vpi_handle_by_name((PLI_BYTE8 *)array_name, top);
    vpi_printf("%s matching-kind=%d/%d legacy-array=%d/%d\n", label,
               property(vpiType, single) == kind, property(vpiType, array) == kind,
               property(vpiArray, single), property(vpiArray, array));
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name("test_vpi_legacy_array_property_in_1364v2005_mode", NULL);
    (void)data;
    if (top == NULL) {
        vpi_printf("top not found\n");
        return 0;
    }

    report(top, "integer", "int_scalar", "int_array", vpiIntegerVar);
    report(top, "time", "time_scalar", "time_array", vpiTimeVar);
    report(top, "real", "real_scalar", "real_array", vpiRealVar);
    return 0;
}

static void register_start(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = on_start;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_start, NULL};

#ifdef __cplusplus
}
#endif
