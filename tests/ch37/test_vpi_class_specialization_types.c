/* VPI application of test_vpi_class_specialization_types (37.32, 37.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_class_specialization_types"
#define MAX 8

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "NULL";
}

static vpiHandle by_name(const char *path)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, path);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static vpiHandle find_class(const char *name)
{
    vpiHandle it = vpi_iterate(vpiClassDefn, NULL), h;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, h), name) == 0) {
            vpi_release_handle(it);
            return h;
        }
    return NULL;
}

static vpiHandle param_assign(vpiHandle spec, const char *name)
{
    vpiHandle it = spec != NULL ? vpi_iterate(vpiParamAssign, spec) : NULL, a, lhs;

    while (it != NULL && (a = vpi_scan(it)) != NULL) {
        lhs = vpi_handle(vpiLhs, a);
        if (lhs != NULL && strcmp(sprop(vpiName, lhs), name) == 0) {
            vpi_release_handle(it);
            return a;
        }
    }
    return NULL;
}

/* The integer value of a parameter assignment's right-hand side. */
static int param_value(vpiHandle spec, const char *name)
{
    vpiHandle a = param_assign(spec, name);
    vpiHandle rhs = a != NULL ? vpi_handle(vpiRhs, a) : NULL;
    s_vpi_value v;

    if (rhs == NULL)
        return -1000;
    v.format = vpiIntVal;
    v.value.integer = -1000;
    vpi_get_value(rhs, &v);
    return (int)v.value.integer;
}

static int named(vpiHandle h)
{
    const char *s = sprop(vpiName, h);
    return s != NULL && s[0] != '\0';
}

static void spec_info(const char *label, vpiHandle spec, const char *defname)
{
    vpi_printf((PLI_BYTE8 *)"%s: classDefn %s %d, classType user %d, automatic %d, "
               "name non-empty %d, W %d\n",
               label, defname,
               vpi_handle(vpiClassDefn, spec) != NULL
               && vpi_compare_objects(vpi_handle(vpiClassDefn, spec), find_class(defname)),
               vpi_get(vpiClassType, spec) == vpiUserDefinedClass,
               (int)vpi_get(vpiAutomatic, spec), named(spec), param_value(spec, "W"));
}

static int unsupported_relations(vpiHandle spec)
{
    static const PLI_INT32 relations[] = {
        vpiVariables, vpiMethods, vpiConstraint, vpiNamedEvent,
        vpiNamedEventArray, vpiTypedef, vpiInternalScope
    };
    int i, n = 0;

    if (spec == NULL)
        return -1;
    for (i = 0; i < (int)(sizeof relations / sizeof relations[0]); i++)
        if (vpi_iterate(relations[i], spec) == NULL)
            n++;
    return n;
}

static void constraints(const char *label, vpiHandle spec)
{
    vpiHandle it = spec != NULL ? vpi_iterate(vpiConstraint, spec) : NULL, c;
    int n = 0;

    vpi_printf((PLI_BYTE8 *)"%s: ", label);
    while (it != NULL && (c = vpi_scan(it)) != NULL && n < MAX) {
        vpi_printf((PLI_BYTE8 *)"%s%s", n ? "," : "", sprop(vpiName, c));
        n++;
    }
    vpi_printf((PLI_BYTE8 *)"%s\n", n ? "" : "none");
}

static PLI_INT32 spec_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle base = find_class("sp_base"), der = find_class("sp_der");
    vpiHandle b8 = by_name("b8"), a2 = by_name("a2"), d3 = by_name("d3");
    vpiHandle b8s, a2s, d3s, ext, lex, m, ms, it, h, proc, procs, base_ts, ext2;
    vpiHandle td, t;

    (void)user_data;
    b8s = b8 != NULL ? vpi_handle(vpiTypespec, b8) : NULL;
    a2s = a2 != NULL ? vpi_handle(vpiTypespec, a2) : NULL;
    d3s = d3 != NULL ? vpi_handle(vpiTypespec, d3) : NULL;
    spec_info("b8 typespec", b8s, "sp_base");
    spec_info("a2 typespec", a2s, "sp_base");
    spec_info("d3 typespec", d3s, "sp_der");
    constraints("d3 constraints", d3s);

    ext2 = d3s != NULL ? vpi_handle(vpiExtends, d3s) : NULL;
    base_ts = ext2;
    vpi_printf((PLI_BYTE8 *)"d3 base: classDefn sp_base %d, W %d\n",
               vpi_handle(vpiClassDefn, base_ts) != NULL
               && vpi_compare_objects(vpi_handle(vpiClassDefn, base_ts), base),
               param_value(base_ts, "W"));
    constraints("d3 base constraints", base_ts);

    {
        int idxs[MAX], ne = 0, i, j;
        vpiHandle e;
        it = base_ts != NULL ? vpi_iterate(vpiVirtualInterfaceVar, base_ts) : NULL;
        while (it != NULL && (e = vpi_scan(it)) != NULL && ne < MAX)
            idxs[ne++] = (int)vpi_get(vpiIndex, e);
        for (i = 0; i < ne; i++)
            for (j = i + 1; j < ne; j++)
                if (idxs[i] > idxs[j]) {
                    int t = idxs[i];
                    idxs[i] = idxs[j];
                    idxs[j] = t;
                }
        vpi_printf((PLI_BYTE8 *)"d3 base virtual interface elements: %d (indices", ne);
        for (i = 0; i < ne; i++)
            vpi_printf((PLI_BYTE8 *)"%s%d", i ? "," : " ", idxs[i]);
        vpi_printf((PLI_BYTE8 *)")\n");
    }
    {
        int nvar = 0, one_array = 0;
        it = base_ts != NULL ? vpi_iterate(vpiVariables, base_ts) : NULL;
        while (it != NULL && (h = vpi_scan(it)) != NULL) {
            nvar++;
            if (vpi_get(vpiType, h) == vpiArrayVar
                && strcmp(sprop(vpiName, h), "vifs") == 0)
                one_array++;
        }
        vpi_printf((PLI_BYTE8 *)"d3 base variables: %d, one vifs array var %d\n",
                   nvar, one_array == 1);
    }

    {
        int n = 0, all_back = 1, all_user = 1, all_named = 1;
        it = der != NULL ? vpi_iterate(vpiClassTypespec, der) : NULL;
        while (it != NULL && (h = vpi_scan(it)) != NULL) {
            n++;
            if (vpi_handle(vpiClassDefn, h) == NULL
                || !vpi_compare_objects(vpi_handle(vpiClassDefn, h), der))
                all_back = 0;
            if (vpi_get(vpiClassType, h) != vpiUserDefinedClass)
                all_user = 0;
            if (!named(h))
                all_named = 0;
        }
        vpi_printf((PLI_BYTE8 *)"sp_der class typespecs: some %d, all back %d, "
                   "all user %d, all named %d\n", n, all_back, all_user, all_named);
    }

    ext = der != NULL ? vpi_handle(vpiExtends, der) : NULL;
    lex = ext != NULL ? vpi_handle(vpiClassTypespec, ext) : NULL;
    {
        vpiHandle pa = param_assign(lex, "W");
        vpiHandle rhs = pa != NULL ? vpi_handle(vpiRhs, pa) : NULL;
        vpi_printf((PLI_BYTE8 *)"sp_der extends lexical: RHS name %s, unsupported relations %d\n",
                   sprop(vpiName, rhs), unsupported_relations(lex));
    }
    td = der != NULL ? vpi_iterate(vpiTypedef, der) : NULL;
    while (td != NULL && (t = vpi_scan(td)) != NULL)
        if (strcmp(sprop(vpiName, t), "sp_nested_t") == 0)
            vpi_printf((PLI_BYTE8 *)"sp_der typedef lexical: W %d, "
                       "unsupported relations %d\n",
                       param_value(t, "W"), unsupported_relations(t));
    m = NULL;
    it = der != NULL ? vpi_iterate(vpiVariables, der) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, h), "m") == 0)
            m = h;
    ms = m != NULL ? vpi_handle(vpiTypespec, m) : NULL;
    vpi_printf((PLI_BYTE8 *)"sp_der item m lexical: W default %d, unsupported relations %d\n",
               param_value(ms, "W"), unsupported_relations(ms));
    vpi_printf((PLI_BYTE8 *)"sp_der item m virtual interfaces NULL %d\n",
               ms != NULL && vpi_iterate(vpiVirtualInterfaceVar, ms) == NULL);

    proc = by_name("proc");
    procs = proc != NULL ? vpi_handle(vpiTypespec, proc) : NULL;
    vpi_printf((PLI_BYTE8 *)"process typespec: classType process %d, classDefn NULL %d\n",
               vpi_get(vpiClassType, procs) == vpiProcessClass,
               vpi_handle(vpiClassDefn, procs) == NULL);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_spec";
    d.calltf = spec_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
