#include <stddef.h>
#include <stdio.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int report_error(const char *kind, const char *operation)
{
    s_vpi_error_info info = {0};
    if (vpi_chk_error(&info) < vpiError)
        return 0;
    if (info.message != NULL)
        fprintf(stderr, "%s %s error: %s\n", kind, operation, (const char *)info.message);
    return 1;
}

static PLI_INT32 check_aggregate(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle scope, aggregate, member, select_union;
    const char *aggregate_name, *member_name;
    const char *kind;
    s_vpi_value value = {0};
    int is_union, original, updated, read_error, write_error;
    (void)unused;

    if (iterator == NULL)
        return 0;
    select_union = vpi_scan(iterator);
    if (select_union == NULL)
        return 0;
    vpi_release_handle(iterator);

    value.format = vpiIntVal;
    vpi_get_value(select_union, &value);
    is_union = value.value.integer != 0;
    kind = is_union ? "union" : "struct";
    scope = vpi_handle(vpiScope, call);
    aggregate_name = is_union ? "storage_value" : "record_value";
    member_name = is_union ? "storage_value.reading" : "record_value.reading";
    aggregate = vpi_handle_by_name((PLI_BYTE8 *)aggregate_name, scope);
    member = vpi_handle_by_name((PLI_BYTE8 *)member_name, scope);
    if (aggregate == NULL || member == NULL ||
        vpi_get(vpiType, aggregate) != (is_union ? vpiUnionVar : vpiStructVar)) {
        vpi_printf("%s aggregate object missing\n", kind);
        return 0;
    }

    vpi_get_value(member, &value);
    original = (int)value.value.integer;
    value.value.integer = original + 7;
    vpi_put_value(member, &value, NULL, vpiNoDelay);
    vpi_get_value(member, &value);
    updated = (int)value.value.integer;

    vpi_get_value(aggregate, &value);
    read_error = report_error(kind, "read");
    value.format = vpiIntVal;
    value.value.integer = updated;
    vpi_put_value(aggregate, &value, NULL, vpiNoDelay);
    write_error = report_error(kind, "write");

    vpi_printf("%s member=%d updated=%d whole read error=%d whole write error=%d\n",
               kind, original, updated, read_error, write_error);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_aggregate";
    task.calltf = check_aggregate;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
