/* VPI application of test_vpi_property_decl_formals_args (IEEE 1800-2023 37.51, 37.52). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_property_decl_formals_args"
#define MAX 8
#define LEN 64

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "(none)";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void operand_text(vpiHandle h, char *out, size_t len)
{
    if (h == NULL)
        snprintf(out, len, "NULL");
    else if (vpi_get(vpiType, h) == vpiConstant)
        snprintf(out, len, "%d", int_value(h));
    else
        snprintf(out, len, "%s", name_of(h));
}

static vpiHandle decl_in(const char *scope, const char *name)
{
    vpiHandle s = vpi_handle_by_name((PLI_BYTE8 *)scope, NULL), it, h, found = NULL;
    it = s != NULL ? vpi_iterate(vpiPropertyDecl, s) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), name) == 0)
            found = h;
    return found;
}

static void instance(const char *assertion)
{
    char full[96], text[32];
    vpiHandle as, p, it, h;

    snprintf(full, sizeof full, "%s.%s", TOP, assertion);
    as = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    p = as != NULL ? vpi_handle(vpiProperty, as) : NULL;
    if (p != NULL && vpi_get(vpiType, p) == vpiPropertySpec)
        p = vpi_handle(vpiPropertyExpr, p);
    if (p == NULL || vpi_get(vpiType, p) != vpiPropertyInst) {
        vpi_printf((PLI_BYTE8 *)"%s: no property instance\n", assertion);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: instance of %s, arguments:", assertion,
               name_of(vpi_handle(vpiPropertyDecl, p)));
    it = vpi_iterate(vpiArgument, p);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        operand_text(h, text, sizeof text);
        vpi_printf((PLI_BYTE8 *)" %s", text);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static const char *direction(vpiHandle h)
{
    switch (vpi_get(vpiDirection, h)) {
    case vpiNoDirection: return "no direction";
    case vpiInput: return "input";
    case vpiOutput: return "output";
    case vpiInout: return "inout";
    default: return "other direction";
    }
}

static const char *typespec(vpiHandle formal)
{
    vpiHandle ts = vpi_handle(vpiTypespec, formal);
    if (ts == NULL)
        return "typespec NULL";
    return vpi_get(vpiType, ts) == vpiIntTypespec ? "int typespec" : "other typespec";
}

static void formals(void)
{
    vpiHandle d = decl_in(TOP, "p_formals"), it, f;

    vpi_printf((PLI_BYTE8 *)"formals of p_formals:");
    it = d != NULL ? vpi_iterate(vpiPropFormalDecl, d) : NULL;
    while (it != NULL && (f = vpi_scan(it)) != NULL)
        vpi_printf((PLI_BYTE8 *)" %s (%s, %s);", name_of(f), direction(f), typespec(f));
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void variables(void)
{
    vpiHandle d = decl_in(TOP, "p_vars"), it, h;
    char names[MAX][LEN];
    int n = 0, i;

    it = d != NULL ? vpi_iterate(vpiVariables, d) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            snprintf(names[n++], LEN, "%s", name_of(h));
    qsort(names, (size_t)n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"variables of p_vars:");
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void full_name(const char *scope, const char *name)
{
    vpiHandle d = decl_in(scope, name);
    vpi_printf((PLI_BYTE8 *)"full name of %s: %s\n", name,
               d != NULL && vpi_get_str(vpiFullName, d) != NULL ? vpi_get_str(vpiFullName, d)
               : "(none)");
}

static void case_property(void)
{
    vpiHandle d = decl_in(TOP, "p_case"), spec, e, it, item, eit, h;
    char items[MAX][LEN];
    int n = 0, i, j, k, conds[MAX];

    spec = d != NULL ? vpi_handle(vpiPropertySpec, d) : NULL;
    e = spec != NULL ? vpi_handle(vpiPropertyExpr, spec) : NULL;
    if (e == NULL || vpi_get(vpiType, e) != vpiCaseProperty) {
        vpi_printf((PLI_BYTE8 *)"p_case: not a case property\n");
        return;
    }
    it = vpi_iterate(vpiCasePropertyItem, e);
    while (it != NULL && (item = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        snprintf(items[n], LEN, "%s <-", name_of(vpi_handle(vpiPropertyExpr, item)));
        eit = vpi_iterate(vpiExpr, item);
        if (eit == NULL)
            snprintf(items[n] + strlen(items[n]), LEN - strlen(items[n]), " iterator NULL");
        k = 0;
        while (eit != NULL && (h = vpi_scan(eit)) != NULL)
            if (k < MAX)
                conds[k++] = int_value(h);
        for (i = 1; i < k; i++)
            for (j = i; j > 0 && conds[j - 1] > conds[j]; j--) {
                int t = conds[j];
                conds[j] = conds[j - 1];
                conds[j - 1] = t;
            }
        for (i = 0; i < k; i++)
            snprintf(items[n] + strlen(items[n]), LEN - strlen(items[n]), " %d", conds[i]);
        n++;
    }
    qsort(items, (size_t)n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"p_case: condition %s, items: %d\n",
               name_of(vpi_handle(vpiCondition, e)), n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", items[i]);
}

static PLI_INT32 props_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    instance("a1");
    instance("a2");
    instance("a3");
    formals();
    variables();
    full_name(TOP, "p_vars");
    full_name(TOP ".g", "p_gen");
    case_property();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_props";
    d.calltf = props_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
