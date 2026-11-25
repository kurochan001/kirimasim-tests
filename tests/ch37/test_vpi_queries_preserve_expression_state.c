/* Query expression structure before the explicit value read. */
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

struct probe {
    vpiHandle expression;
    vpiHandle expected;
    vpiHandle effect_count;
};

static struct probe read_probe(void)
{
    struct probe probe = {0};
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle arguments = call == NULL ? NULL : vpi_iterate(vpiArgument, call);
    if (arguments != NULL && (probe.expression = vpi_scan(arguments)) != NULL &&
        (probe.expected = vpi_scan(arguments)) != NULL &&
        (probe.effect_count = vpi_scan(arguments)) != NULL)
        vpi_release_handle(arguments);
    return probe;
}

static int int_value(vpiHandle object)
{
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(object, &value);
    return (int)value.value.integer;
}

static const char *string_value(vpiHandle object)
{
    s_vpi_value value = {0};
    value.format = vpiStringVal;
    vpi_get_value(object, &value);
    return value.value.str;
}

static int effect_error(void)
{
    s_vpi_error_info info = {0};
    return vpi_chk_error(&info) >= vpiError;
}

static PLI_INT32 property_query(PLI_BYTE8 *unused)
{
    (void)unused;
    struct probe probe = read_probe();
    if (probe.effect_count == NULL) {
        vpi_printf("missing property query arguments\n");
        return 0;
    }
    const char *reference = string_value(probe.expected);
    char expected[32];
    if (reference == NULL || strlen(reference) >= sizeof expected) {
        vpi_printf("missing or oversized property control string\n");
        return 0;
    }
    snprintf(expected, sizeof expected, "%s", reference);
    int before = int_value(probe.effect_count);
    int length = vpi_get(vpiSize, probe.expression);
    int error = effect_error();
    int after_query = int_value(probe.effect_count);
    const char *actual = string_value(probe.expression);
    int value_matches = actual != NULL && strcmp(actual, expected) == 0;
    int after_read = int_value(probe.effect_count);
    vpi_printf("property decision=%d untouched=%d value=%d once=%d\n",
               error || length == (int)strlen(expected),
               before == 0 && after_query == 0, value_matches, after_read == 1);
    return 0;
}

static PLI_INT32 index_query(PLI_BYTE8 *unused)
{
    (void)unused;
    struct probe probe = read_probe();
    if (probe.effect_count == NULL) {
        vpi_printf("missing index query arguments\n");
        return 0;
    }
    int expected = int_value(probe.expected);
    int before = int_value(probe.effect_count);
    vpiHandle index = vpi_handle(vpiIndex, probe.expression);
    int error = effect_error();
    int after_query = int_value(probe.effect_count);
    const char *index_type = index == NULL ? NULL : vpi_get_str(vpiType, index);
    int type_matches = index_type != NULL && strcmp(index_type, "vpiFuncCall") == 0;
    int value = int_value(probe.expression);
    int after_read = int_value(probe.effect_count);
    vpi_printf("relation decision=%d untouched=%d value=%d once=%d\n",
               error || type_matches, before == 0 && after_query == 0,
               value == expected, after_read == 1);
    return 0;
}

static void install_task(const char *name, PLI_INT32 (*call)(PLI_BYTE8 *))
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)name;
    task.calltf = call;
    vpi_register_systf(&task);
}

static void install(void)
{
    install_task("$vt_property_query", property_query);
    install_task("$vt_index_query", index_query);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
