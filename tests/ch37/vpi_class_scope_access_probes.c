#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle find_member(vpiHandle scope, int relation, const char *wanted)
{
    vpiHandle iterator = vpi_iterate(relation, scope), member;
    if (iterator == NULL)
        return NULL;
    while ((member = vpi_scan(iterator)) != NULL) {
        const PLI_BYTE8 *name = vpi_get_str(vpiName, member);
        if (name != NULL && strcmp((const char *)name, wanted) == 0) {
            vpi_release_handle(iterator);
            return member;
        }
    }
    return NULL;
}

static int report_error(const char *name, const char *operation)
{
    s_vpi_error_info info = {0};
    if (vpi_chk_error(&info) < vpiError)
        return 0;
    if (info.message != NULL)
        fprintf(stderr, "%s %s error: %s\n", name, operation, (const char *)info.message);
    return 1;
}

static void reject_value_operations(vpiHandle member, const char *name)
{
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(member, &value);
    int read_failed = report_error(name, "read");
    value.format = vpiIntVal;
    value.value.integer = 81;
    vpi_put_value(member, &value, NULL, vpiNoDelay);
    int write_failed = report_error(name, "write");
    vpi_printf("%s read=%d write=%d\n", name, read_failed, write_failed);
}

static void update_shared(vpiHandle member)
{
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(member, &value);
    int before = (int)value.value.integer;
    value.value.integer = 43;
    vpi_put_value(member, &value, NULL, vpiNoDelay);
    int write_failed = report_error("shared", "write");
    vpi_printf("shared read=%d write error=%d\n", before, write_failed);
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    (void)unused;
    if (call == NULL)
        return 0;
    vpiHandle iterator = vpi_iterate(vpiArgument, call);
    vpiHandle argument = iterator != NULL ? vpi_scan(iterator) : NULL;
    if (argument == NULL)
        return 0;
    s_vpi_value selector = {0};
    selector.format = vpiIntVal;
    vpi_get_value(argument, &selector);
    int use_typespec = (int)selector.value.integer;
    vpi_release_handle(iterator);

    vpiHandle module = vpi_handle(vpiScope, call);
    vpiHandle variable = module == NULL ? NULL :
        vpi_handle_by_name((PLI_BYTE8 *)"object_instance", module);
    vpiHandle typespec = variable == NULL ? NULL : vpi_handle(vpiTypespec, variable);
    if (typespec == NULL)
        return 0;
    vpiHandle scope = use_typespec ? typespec : vpi_handle(vpiClassDefn, typespec);
    if (scope == NULL)
        return 0;
    vpiHandle own = find_member(scope, vpiVariables, "own");
    vpiHandle shared = find_member(scope, vpiVariables, "shared");
    vpiHandle pulse = find_member(scope, vpiNamedEvent, "pulse");
    if (own == NULL || shared == NULL)
        return 0;

    reject_value_operations(own, "own");
    if (use_typespec)
        update_shared(shared);
    else
        reject_value_operations(shared, "shared");
    if (pulse != NULL) {
        s_vpi_value value = {.format = vpiObjTypeVal};
        vpi_get_value(pulse, &value);
        int read_failed = report_error("pulse", "read");
        vpi_put_value(pulse, NULL, NULL, vpiNoDelay);
        int write_failed = report_error("pulse", "write");
        vpi_printf("pulse read=%d write=%d\n", read_failed, write_failed);
    }

    vpiHandle live = vpi_handle_by_name((PLI_BYTE8 *)"live_pulse", module);
    if (live != NULL)
        vpi_put_value(live, NULL, NULL, vpiNoDelay);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_members";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
