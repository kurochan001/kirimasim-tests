/* VPI application of test_vpi_variable_path_tchk_terms (IEEE 1800-2023 37.17, 37.39, 37.40). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define CELL "test_vpi_variable_path_tchk_terms.c"

static const char *direction(vpiHandle h)
{
    switch (vpi_get(vpiDirection, h)) {
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other";
    }
}

static const char *edge(vpiHandle h)
{
    switch (vpi_get(vpiEdge, h)) {
    case vpiNoEdge: return "no edge";
    case vpiPosedge: return "posedge";
    case vpiNegedge: return "negedge";
    default: return "other edge";
    }
}

/* The vpiName of the expression of a terminal. */
static void expr_name(vpiHandle term, char *out, size_t size)
{
    vpiHandle e = vpi_handle(vpiExpr, term);
    PLI_BYTE8 *s = e != NULL ? vpi_get_str(vpiName, e) : NULL;
    snprintf(out, size, "%s", s != NULL ? s : "NULL");
}

static void show(const char *var)
{
    char full[96], name[64];
    vpiHandle v, t;

    snprintf(full, sizeof full, "%s.%s", CELL, var);
    v = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (v == NULL || vpi_get(vpiType, v) != vpiLogicVar) {
        vpi_printf((PLI_BYTE8 *)"c.%s: not a logic var\n", var);
        return;
    }
    t = vpi_handle(vpiPathTerm, v);
    vpi_printf((PLI_BYTE8 *)"path term of c.%s: ", var);
    if (t == NULL) {
        vpi_printf((PLI_BYTE8 *)"NULL\n");
    } else if (vpi_get(vpiType, t) != vpiPathTerm) {
        vpi_printf((PLI_BYTE8 *)"not a path term\n");
    } else {
        expr_name(t, name, sizeof name);
        vpi_printf((PLI_BYTE8 *)"path term, direction %s, expr %s\n", direction(t), name);
    }
    t = vpi_handle(vpiTchkTerm, v);
    vpi_printf((PLI_BYTE8 *)"tchk term of c.%s: ", var);
    if (t == NULL) {
        vpi_printf((PLI_BYTE8 *)"NULL\n");
    } else if (vpi_get(vpiType, t) != vpiTchkTerm) {
        vpi_printf((PLI_BYTE8 *)"not a tchk term\n");
    } else {
        expr_name(t, name, sizeof name);
        vpi_printf((PLI_BYTE8 *)"tchk term, %s, expr %s\n", edge(t), name);
    }
}

static PLI_INT32 terms_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("y");
    show("d");
    show("z");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_terms";
    d.calltf = terms_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
