/* VPI application of test_vpi_property_sequence_decls (IEEE 1800-2023 37.51, 37.53). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *name_or_none(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "(none)";
}

static const char *direction(PLI_INT32 d)
{
    switch (d) {
    case vpiNoDirection: return "no direction";
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other direction";
    }
}

/* Prints each declaration of the given type and its formal arguments. */
static void describe(PLI_INT32 decl_type, PLI_INT32 formal_type, const char *label)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_property_sequence_decls", NULL);
    vpiHandle it = vpi_iterate(decl_type, top), decl, fit, formal, init;
    s_vpi_value v;
    char name[32];

    if (it == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: none\n", label);
        return;
    }
    while ((decl = vpi_scan(it)) != NULL) {
        vpi_printf((PLI_BYTE8 *)"%s %s:\n", label, name_or_none(decl));
        fit = vpi_iterate(formal_type, decl);
        if (fit != NULL)
            while ((formal = vpi_scan(fit)) != NULL) {
                snprintf(name, sizeof name, "%s", name_or_none(formal));
                init = vpi_handle(vpiExpr, formal);
                vpi_printf((PLI_BYTE8 *)"  %s: %s, %s", name,
                           vpi_handle(vpiTypespec, formal) ? "typed" : "untyped",
                           direction(vpi_get(vpiDirection, formal)));
                if (init != NULL) {
                    v.format = vpiIntVal;
                    vpi_get_value(init, &v);
                    vpi_printf((PLI_BYTE8 *)", default %d", (int)v.value.integer);
                }
                vpi_printf((PLI_BYTE8 *)"\n");
            }
    }
}

static PLI_INT32 decls_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    describe(vpiSequenceDecl, vpiSeqFormalDecl, "sequence");
    describe(vpiPropertyDecl, vpiPropFormalDecl, "property");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_decls";
    d.calltf = decls_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
