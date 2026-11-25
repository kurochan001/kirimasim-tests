/* IEEE 1800-2023 37.25: compare member names with their nested typespec names. */
#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

static vpiHandle find_member(vpiHandle scope, const char *wanted)
{
    vpiHandle iter = scope ? vpi_iterate(vpiTypespecMember, scope) : NULL;
    vpiHandle member, found = NULL;

    while (iter && (member = vpi_scan(iter))) {
        const char *name = vpi_get_str(vpiName, member);
        if (name && strcmp(name, wanted) == 0)
            found = member;
    }
    return found;
}

static vpiHandle typespec_of(vpiHandle object)
{
    return object ? vpi_handle(vpiTypespec, object) : NULL;
}

static void inspect(vpiHandle container, const char *member_name, const char *typedef_name)
{
    vpiHandle member = find_member(container, member_name);
    vpiHandle nested = typespec_of(member);
    vpiHandle value = find_member(nested, "value");
    vpiHandle value_type = typespec_of(value);
    const char *name = nested ? vpi_get_str(vpiName, nested) : NULL;
    int name_ok = typedef_name ? (name && strcmp(name, typedef_name) == 0)
                               : (name == NULL || name[0] == '\0');

    if (nested && !name_ok)
        vpi_printf("%s: unexpected typespec name %s\n", member_name, name ? name : "<NULL>");
    vpi_printf("%s: member=%d struct=%d inner_int=%d name_ok=%d\n", member_name,
               member && vpi_get(vpiType, member) == vpiTypespecMember,
               nested && vpi_get(vpiType, nested) == vpiStructTypespec,
               value_type && vpi_get(vpiType, value_type) == vpiIntTypespec,
               nested && name_ok);
}

static PLI_INT32 observe(p_cb_data callback)
{
    vpiHandle variable = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_inline_member_typespec_name.specimen", NULL);
    vpiHandle container = typespec_of(variable);

    (void)callback;
    inspect(container, "inline_field", NULL);
    inspect(container, "named_field", "named_t");
    return 0;
}

static void register_all(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_all, NULL};
