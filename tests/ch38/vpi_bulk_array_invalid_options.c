#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void report_error(const char *label)
{
    int error_reported = vpi_chk_error(NULL) >= vpiError;
    vpi_printf("%s vpi-error=%d\n", label, error_reported);
}

static PLI_INT32 check_flags(PLI_BYTE8 *unused)
{
    static const PLI_INT32 invalid_flags[] = {
        vpiInertialDelay, vpiTransportDelay, vpiPureTransportDelay, 0x10000
    };
    static const char *const names[] = {"inertial", "transport", "pure transport", "unknown flag"};
    PLI_INT32 one_value[2] = {52, 61};
    PLI_INT32 replacement[2] = {87, 92};
    PLI_INT32 index[1] = {1};
    s_vpi_arrayvalue values = {0};
    size_t i;
    (void)unused;

    vpiHandle array = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_bulk_array_rejects_delay_and_unknown_flags.items", NULL);
    if (array == NULL) {
        vpi_printf("array not found\n");
        return 0;
    }
    values.format = vpiIntVal;
    values.flags = vpiOneValue;
    values.value.integers = one_value;
    vpi_put_value_array(array, &values, index, 2);
    report_error("one value");

    index[0] = 0;
    values.value.integers = replacement;
    for (i = 0; i < sizeof invalid_flags / sizeof invalid_flags[0]; ++i) {
        values.flags = invalid_flags[i];
        vpi_put_value_array(array, &values, index, 2);
        report_error(names[i]);
    }
    return 0;
}

static PLI_INT32 check_formats(PLI_BYTE8 *unused)
{
    PLI_INT32 replacement[3] = {91, 83, 62};
    PLI_INT32 index[1] = {1};
    s_vpi_arrayvalue values = {0};
    (void)unused;
    vpiHandle array = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_bulk_array_rejects_unsupported_and_inconsistent_formats.items", NULL);
    if (array == NULL) {
        vpi_printf("array not found\n");
        return 0;
    }

    values.format = vpiStringVal;
    vpi_get_value_array(array, &values, index, 2);
    report_error("string get");

    values.format = vpiShortRealVal;
    vpi_get_value_array(array, &values, index, 2);
    report_error("shortreal get");

    values.format = vpiStringVal;
    values.flags = 0;
    values.value.integers = replacement;
    vpi_put_value_array(array, &values, index, 2);
    report_error("string put");

    values.format = vpiIntVal;
    values.flags = 0;
    vpi_get_value_array(array, &values, index, 2);
    if (vpi_chk_error(NULL) >= vpiError || values.value.integers == NULL)
        vpi_printf("int control unavailable\n");
    else
        vpi_printf("int control=%d/%d\n", (int)values.value.integers[0],
                   (int)values.value.integers[1]);
    return 0;
}

static void register_tasks(void)
{
    s_vpi_systf_data flags = {0}, formats = {0};
    flags.type = formats.type = vpiSysTask;
    flags.tfname = (PLI_BYTE8 *)"$vt_bad_bulk_flags";
    flags.calltf = check_flags;
    formats.tfname = (PLI_BYTE8 *)"$vt_bad_bulk_formats";
    formats.calltf = check_formats;
    vpi_register_systf(&flags);
    vpi_register_systf(&formats);
}

void (*vlog_startup_routines[])(void) = {register_tasks, NULL};

#ifdef __cplusplus
}
#endif
