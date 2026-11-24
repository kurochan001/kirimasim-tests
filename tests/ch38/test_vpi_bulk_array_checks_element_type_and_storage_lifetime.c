#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "sv_vpi_user.h"

static vpiHandle find_local_array(PLI_INT32 relation, vpiHandle parent)
{
    vpiHandle iterator = parent == NULL ? NULL : vpi_iterate(relation, parent);
    vpiHandle handle;
    while (iterator != NULL && (handle = vpi_scan(iterator)) != NULL) {
        const char *name = vpi_get_str(vpiName, handle);
        if (name != NULL && strcmp(name, "local_items") == 0) {
            vpi_release_handle(iterator);
            return handle;
        }
    }
    return NULL;
}

static PLI_INT32 observe(PLI_BYTE8 *user_data)
{
    static const char *const names[] = {
        "packed elements", "net elements", "unpacked elements", "string elements",
        "dynamic array", "automatic local", "static local"
    };
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call == NULL ? NULL : vpi_iterate(vpiArgument, call);
    s_vpi_value selector = {0};
    s_vpi_arrayvalue values = {0};
    PLI_INT32 index[1] = {0};
    PLI_INT32 replacement = 77;
    (void)user_data;
    if (iterator == NULL)
        return 0;

    vpiHandle selection = vpi_scan(iterator);
    if (selection == NULL)
        return 0;
    selector.format = vpiIntVal;
    vpi_get_value(selection, &selector);
    int mode = selector.value.integer;
    if (mode < 0 || mode >= (int)(sizeof(names) / sizeof(names[0]))) {
        vpi_release_handle(iterator);
        return 0;
    }

    vpiHandle array;
    if (mode == 5) {
        array = find_local_array(vpiAutomatics, vpi_handle(vpiFrame, NULL));
    } else if (mode == 6) {
        vpiHandle task = vpi_handle_by_name(
            (PLI_BYTE8 *)"test_vpi_bulk_array_checks_element_type_and_storage_lifetime.inspect_static_array", NULL);
        array = find_local_array(vpiVariables, task);
    } else {
        array = vpi_scan(iterator);
        if (array == NULL)
            iterator = NULL;
        if (array != NULL && vpi_get(vpiType, array) == vpiRefObj)
            array = vpi_handle(vpiActual, array);
    }
    if (iterator != NULL)
        vpi_release_handle(iterator);
    if (array == NULL) {
        vpi_printf("%s missing array handle\n", names[mode]);
        return 0;
    }

    if (mode == 5 || mode == 6) {
        PLI_INT32 automatic = vpi_get(vpiAutomatic, array);
        vpi_printf("%s automatic=%d\n", names[mode], (int)automatic);
    }
    values.format = vpiIntVal;
    vpi_get_value_array(array, &values, index, 2);
    int get_error = vpi_chk_error(NULL) >= vpiError;
    if (values.value.integers != NULL) {
        vpi_printf("%s get=%d values=%d,%d\n", names[mode], get_error,
                   (int)values.value.integers[0], (int)values.value.integers[1]);
    } else {
        vpi_printf("%s get=%d values=none\n", names[mode], get_error);
    }

    values.value.integers = &replacement;
    vpi_put_value_array(array, &values, index, 1);
    int put_error = vpi_chk_error(NULL) >= vpiError;
    vpi_printf("%s put=%d\n", names[mode], put_error);
    return 0;
}

static void register_observation(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_bulk_array";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_observation, NULL};

#ifdef __cplusplus
}
#endif
