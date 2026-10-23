/* VPI application of test_vpi_instance_enclosure_names (IEEE 1800-2023 37.10). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_instance_enclosure_names"

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiPackage: return "package";
    case vpiModule: return "module";
    case vpiInterface: return "interface";
    case vpiProgram: return "program";
    default: return "other type";
    }
}

/* The full name of a package should end with "::" (37.10 detail 5); a final
   "::" is removed so that only the required part is printed. */
static char *instance_name(vpiHandle inst)
{
    char *s = copy(vpi_get_str(vpiFullName, inst));
    size_t n = strlen(s);
    if (vpi_get(vpiType, inst) == vpiPackage && n > 2 && strcmp(s + n - 2, "::") == 0)
        s[n - 2] = '\0';
    return s;
}

static void show(vpiHandle obj, int with_module)
{
    vpiHandle inst, mod;
    char *name, *full;

    if (obj == NULL) {
        vpi_printf("object not found\n");
        return;
    }
    name = copy(vpi_get_str(vpiName, obj));
    full = copy(vpi_get_str(vpiFullName, obj));
    vpi_printf("%s: full name %s", name, full);
    inst = vpi_handle(vpiInstance, obj);
    if (inst == NULL)
        vpi_printf(", instance NULL");
    else if (vpi_get(vpiType, inst) == vpiPackage && vpi_get(vpiUnit, inst) == 1)
        vpi_printf(", instance package (vpiUnit 1)");
    else if (vpi_get(vpiType, inst) == vpiPackage)
        vpi_printf(", instance package %s (vpiUnit %d)", instance_name(inst),
                   (int)vpi_get(vpiUnit, inst));
    else
        vpi_printf(", instance %s %s", kind(inst), instance_name(inst));
    if (with_module) {
        mod = vpi_handle(vpiModule, obj);
        if (mod == NULL)
            vpi_printf(", module NULL");
        else
            vpi_printf(", module %s", copy(vpi_get_str(vpiFullName, mod)));
    }
    vpi_printf("\n");
}

static vpiHandle first(PLI_INT32 type, vpiHandle ref)
{
    vpiHandle it = ref ? vpi_iterate(type, ref) : NULL, h;
    if (it == NULL)
        return NULL;
    h = vpi_scan(it);
    if (h != NULL)
        vpi_free_object(it);
    return h;
}

static vpiHandle by_name(const char *rest)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, rest);
    return vpi_handle_by_name(full, NULL);
}

static PLI_INT32 enclosure_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle args = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle cu_var = vpi_scan(args), pv = vpi_scan(args), pt, cls;

    (void)user_data;
    if (pv != NULL)
        vpi_free_object(args);
    show(cu_var, 1);
    show(pv, 1);
    pt = first(vpiTaskFunc, pv ? vpi_handle(vpiInstance, pv) : NULL);
    show(pt, 1);
    show(first(vpiVariables, pt), 1);
    show(by_name("u.lv"), 1);
    show(by_name("u.blk.bv"), 1);
    cls = first(vpiClassDefn, by_name("u"));
    show(cls, 1);
    show(first(vpiVariables, cls), 1);
    show(by_name("ifc.iv"), 0);
    show(by_name("pr.prv"), 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_enclosure";
    d.calltf = enclosure_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
