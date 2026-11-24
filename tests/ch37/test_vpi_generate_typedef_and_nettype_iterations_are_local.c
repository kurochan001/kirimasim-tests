#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

/* Some headers expose the relationship only under the declaration type. */
#ifndef vpiNetTypedef
#define vpiNetTypedef vpiNettypeDecl
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int only_local(vpiHandle scope, PLI_INT32 kind, const char *expected)
{
    vpiHandle iterator = scope != NULL ? vpi_iterate(kind, scope) : NULL;
    vpiHandle declaration;
    int matches = 0, total = 0;
    while (iterator != NULL && (declaration = vpi_scan(iterator)) != NULL) {
        const char *name = vpi_get_str(vpiName, declaration);
        matches += name != NULL && strcmp(name, expected) == 0;
        total++;
    }
    return total == 1 && matches == 1;
}

static void report(vpiHandle scope, const char *label, const char *type, const char *nettype)
{
    vpi_printf("%s local typedef=%d local nettype=%d\n", label,
               only_local(scope, vpiTypedef, type), only_local(scope, vpiNetTypedef, nettype));
}

static PLI_INT32 observe(p_cb_data data)
{
    vpiHandle outer = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_generate_typedef_and_nettype_iterations_are_local.outer", NULL);
    vpiHandle inner = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_generate_typedef_and_nettype_iterations_are_local.outer.inner", NULL);
    (void)data;
    report(outer, "outer", "outer_word_t", "outer_bus_t");
    report(inner, "inner", "inner_word_t", "inner_bus_t");
    return 0;
}

static void register_observation(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_observation, NULL};

#ifdef __cplusplus
}
#endif
