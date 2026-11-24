#include <stddef.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_property_and_sequence_routes_match_scope_iteration"
#define CTRL_TOP "test_vpi_assertion_control_rejects_property_and_sequence_instance_handles"

static int includes_assertion(vpiHandle scope, vpiHandle named)
{
    vpiHandle iterator = vpi_iterate(vpiAssertion, scope);
    vpiHandle item;
    int matches = 0;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL)
        matches += named != NULL && vpi_compare_objects(named, item);
    return matches;
}

static vpiHandle declaration_in_scope(vpiHandle scope, PLI_INT32 kind, const char *name)
{
    vpiHandle iterator = vpi_iterate(kind, scope);
    vpiHandle item, match = NULL;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        const char *current = vpi_get_str(vpiName, item);
        if (current != NULL && strcmp(current, name) == 0)
            match = item;
    }
    return match;
}

static vpiHandle assertion_operand(vpiHandle assertion)
{
    vpiHandle instance = assertion != NULL ? vpi_handle(vpiProperty, assertion) : NULL;
    if (instance != NULL && vpi_get(vpiType, instance) == vpiPropertySpec)
        instance = vpi_handle(vpiPropertyExpr, instance);
    return instance;
}

static void compare_routes(vpiHandle scope, const char *kind, const char *label,
                           PLI_INT32 instance_type, PLI_INT32 decl_type, const char *name)
{
    vpiHandle assertion = vpi_handle_by_name((PLI_BYTE8 *)label, scope);
    vpiHandle instance = assertion_operand(assertion);
    int has_instance = instance != NULL && vpi_get(vpiType, instance) == instance_type;
    vpiHandle decl = has_instance ? vpi_handle(decl_type, instance) : NULL;
    vpiHandle from_scope = declaration_in_scope(scope, decl_type, name);
    const char *comparison = decl != NULL && from_scope != NULL
                          && vpi_compare_objects(decl, from_scope) ? "same" : "different";
    vpi_printf("%s scope-assertion=%d instance=%d declaration=%s\n",
               kind, includes_assertion(scope, assertion), has_instance, comparison);
}

static PLI_INT32 observe(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpiHandle scope = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    if (scope == NULL) {
        vpi_printf("scope missing\n");
        return 0;
    }
    compare_routes(scope, "property", "asserted", vpiPropertyInst, vpiPropertyDecl, "p_hold");
    compare_routes(scope, "sequence", "observed_sequence", vpiSequenceInst, vpiSequenceDecl, "s_span");
    return 0;
}

static PLI_INT32 control_targets(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpiHandle iterator = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle argument = iterator != NULL ? vpi_scan(iterator) : NULL;
    if (argument == NULL)
        return 0;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(argument, &value);
    vpi_release_handle(iterator);

    vpiHandle assert_target = vpi_handle_by_name((PLI_BYTE8 *)CTRL_TOP ".asserted", NULL);
    vpiHandle cover_target = vpi_handle_by_name((PLI_BYTE8 *)CTRL_TOP ".observed_sequence", NULL);
    int statement = value.value.integer;
    if (!statement) {
        assert_target = assertion_operand(assert_target);
        cover_target = assertion_operand(cover_target);
        if (assert_target == NULL || vpi_get(vpiType, assert_target) != vpiPropertyInst ||
            cover_target == NULL || vpi_get(vpiType, cover_target) != vpiSequenceInst) {
            vpi_printf("missing instance operand\n");
            return 0;
        }
    }
    if (assert_target == NULL || cover_target == NULL) {
        vpi_printf("missing assertion statement\n");
        return 0;
    }
    PLI_INT32 property = vpi_control(vpiAssertionDisable, assert_target);
    PLI_INT32 sequence = vpi_control(vpiAssertionDisable, cover_target);
    vpi_printf("disable %s property=%d sequence=%d\n",
               statement ? "statement" : "operand", (int)property, (int)sequence);
    return 0;
}

static void register_setup(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_compare_routes";
    task.calltf = observe;
    vpi_register_systf(&task);
    task.tfname = (PLI_BYTE8 *)"$vt_control_targets";
    task.calltf = control_targets;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_setup, NULL};

#ifdef __cplusplus
}
#endif
