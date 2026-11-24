#include <stddef.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_property_variables_expose_declarations_without_values"

static vpiHandle declarations(void)
{
    vpiHandle module = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    if (module == NULL)
        return NULL;

    vpiHandle declarations = vpi_iterate(vpiPropertyDecl, module), item, property = NULL;
    while (declarations != NULL && (item = vpi_scan(declarations)) != NULL) {
        const char *name = vpi_get_str(vpiName, item);
        if (name != NULL && strcmp(name, "sample_and_match") == 0)
            property = item;
    }
    return property != NULL ? vpi_iterate(vpiVariables, property) : NULL;
}

static unsigned unavailable(vpiHandle variable)
{
    s_vpi_value probe = {0};
    const PLI_INT32 sentinel = -1728571825;
    probe.format = vpiIntVal;
    probe.value.integer = sentinel;
    vpi_get_value(variable, &probe);
    s_vpi_error_info error = {0};
    return vpi_chk_error(&error) >= vpiError || probe.format == vpiSuppressVal ||
           (probe.format == vpiIntVal && probe.value.integer == sentinel);
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle locals = declarations(), item, saved = NULL;
    unsigned count = 0;
    while (locals != NULL && (item = vpi_scan(locals)) != NULL) {
        ++count;
        const char *name = vpi_get_str(vpiName, item);
        if (name != NULL && strcmp(name, "saved") == 0 && vpi_get(vpiType, item) == vpiIntVar)
            saved = item;
    }

    unsigned no_read = 0;
    if (saved != NULL) {
        no_read = unavailable(saved);
        s_vpi_value attempted_write = {0};
        attempted_write.format = vpiIntVal;
        attempted_write.value.integer = 255;
        vpi_put_value(saved, &attempted_write, NULL, vpiNoDelay);
    }
    vpi_printf("locals=%u saved declaration=%d read unavailable=%u\n",
               count, saved != NULL, no_read);
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = "$vt_property_decl_value";
    definition.calltf = inspect;
    vpi_register_systf(&definition);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
