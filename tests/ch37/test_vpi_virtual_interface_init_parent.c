/* VPI application of test_vpi_virtual_interface_init_parent (IEEE 1800-2023 37.29, 37.30). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_virtual_interface_init_parent"

/* vpi_get_str reuses its buffer (38.11), so every string is copied; NULL is shown. */
static char *str(PLI_BYTE8 *s)
{
    const char *t = s ? s : "NULL";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiInterface: return "interface";
    case vpiVirtualInterfaceVar: return "virtual interface var";
    case vpiInterfaceTypespec: return "interface typespec";
    default: return "other type";
    }
}

static void variable(const char *name)
{
    vpiHandle v = find(name), e;
    if (v == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    vpi_printf("%s: %s, name %s, full name %s", name, kind(v), str(vpi_get_str(vpiName, v)),
               str(vpi_get_str(vpiFullName, v)));
    e = vpi_handle(vpiExpr, v);
    if (e == NULL)
        vpi_printf(", expr NULL\n");
    else
        vpi_printf(", expr %s %s, is b1 %d\n", kind(e), str(vpi_get_str(vpiName, e)),
                   same(e, find("b1")));
}

static vpiHandle typedef_named(vpiHandle scope, const char *name)
{
    vpiHandle it = vpi_iterate(vpiTypedef, scope), t, found = NULL;
    while (it != NULL && (t = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *n = vpi_get_str(vpiName, t);
        if (found == NULL && n != NULL && strcmp(n, name) == 0)
            found = t;
    }
    return found;
}

static void parent(const char *label, vpiHandle t)
{
    vpiHandle p = vpi_handle(vpiParent, t);
    vpi_printf("%s: %s, modport %d, def name %s, parent ", label, kind(t),
               (int)vpi_get(vpiIsModPort, t), str(vpi_get_str(vpiDefName, t)));
    if (p == NULL)
        vpi_printf("NULL\n");
    else
        vpi_printf("%s (modport %d, def name %s)\n", kind(p), (int)vpi_get(vpiIsModPort, p),
                   str(vpi_get_str(vpiDefName, p)));
}

static PLI_INT32 vif_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle v4 = top ? typedef_named(top, "v4_t") : NULL;
    vpiHandle mp = top ? typedef_named(top, "mp_t") : NULL;
    vpiHandle it, pa, lhs, rhs;
    int n = 0;

    (void)user_data;
    variable("vi_init");
    variable("vi_none");
    variable("blk.vi_blk");
    if (v4 == NULL || mp == NULL) {
        vpi_printf("typedefs not found\n");
        return 0;
    }
    it = vpi_iterate(vpiParamAssign, v4);
    while (it != NULL && (pa = vpi_scan(it)) != NULL) {
        n++;
        lhs = vpi_handle(vpiLhs, pa);
        rhs = vpi_handle(vpiRhs, pa);
        vpi_printf("param assign of v4_t: %s = %d, its interface typespec is v4_t %d\n",
                   lhs ? str(vpi_get_str(vpiName, lhs)) : "NULL", rhs ? int_value(rhs) : -1,
                   same(vpi_handle(vpiInterfaceTypespec, pa), v4));
    }
    vpi_printf("param assigns of v4_t: %d\n", n);
    parent("v4_t", v4);
    parent("mp_t", mp);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_vif";
    d.calltf = vif_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
