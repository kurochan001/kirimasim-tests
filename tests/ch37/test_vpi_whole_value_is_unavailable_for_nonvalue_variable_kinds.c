#include <stddef.h>
#include <stdlib.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_whole_value_is_unavailable_for_nonvalue_variable_kinds"

static vpiHandle named(const char *full_name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)full_name, NULL);
}

static void unavailable(const char *label, vpiHandle handle, PLI_INT32 expected_type)
{
    if (handle == NULL) {
        vpi_printf("%s: missing handle\n", label);
        return;
    }

    unsigned correct_type = vpi_get(vpiType, handle) == expected_type;
    const PLI_INT32 untouched = -2047281536;
    s_vpi_value result = {0};
    result.format = vpiIntVal;
    result.value.integer = untouched;

    vpi_get_value(handle, &result);
    s_vpi_error_info error = {0};
    unsigned no_value = vpi_chk_error(&error) >= vpiWarning || result.format == vpiSuppressVal ||
                        (result.format == vpiIntVal && result.value.integer == untouched);
    vpi_printf("%s kind=%u unavailable=%u\n", label, correct_type, no_value);
}

static void vector(const char *label, vpiHandle handle)
{
    s_vpi_value value = {0};
    if (handle == NULL) {
        vpi_printf("%s: missing handle\n", label);
        return;
    }
    value.format = vpiHexStrVal;
    vpi_get_value(handle, &value);
    char *end = NULL;
    const char *text = value.format == vpiHexStrVal ? value.value.str : NULL;
    unsigned long parsed = text != NULL ? strtoul(text, &end, 16) : 0;
    if (end != NULL && end != text && *end == '\0' && parsed <= 0xfffful)
        vpi_printf("%s vector=%d value=%04lx\n", label, (int)vpi_get(vpiVector, handle), parsed);
    else
        vpi_printf("%s: no hexadecimal value\n", label);
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle array = named(TOP ".numbers");
    unavailable("array", array, vpiArrayVar);
    unavailable("class", named(TOP ".object_handle"), vpiClassVar);
    unavailable("virtual interface", named(TOP ".selected"), vpiVirtualInterfaceVar);
    unavailable("unpacked struct", named(TOP ".mixed"), vpiStructVar);
    unavailable("unpacked union", named(TOP ".untagged"), vpiUnionVar);

    vpiHandle element = array != NULL ? vpi_handle_by_index(array, 1) : NULL;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    value.value.integer = -1;
    if (element != NULL)
        vpi_get_value(element, &value);
    vpi_printf("array element read=%d\n", (int)value.value.integer);
    vector("packed struct", named(TOP ".packed_fields"));
    vector("packed union", named(TOP ".packed_word"));
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = "$vt_probe_nonvalue_variables";
    definition.calltf = inspect;
    vpi_register_systf(&definition);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
