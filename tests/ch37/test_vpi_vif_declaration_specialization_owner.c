/* IEEE 1800-2023 37.32: declaration-to-owning-specialization relation. */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_vif_declaration_specialization_owner"

static int same(vpiHandle a, vpiHandle b)
{
    return a && b && vpi_compare_objects(a, b) ? 1 : 0;
}

static vpiHandle specification(const char *name)
{
    char path[160];
    vpiHandle var;
    snprintf(path, sizeof path, "%s.%s", TOP, name);
    var = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    return var ? vpi_handle(vpiClassTypespec, var) : NULL;
}

static int parameter_id(vpiHandle spec)
{
    vpiHandle it, h;
    int result = -99;
    if (!spec)
        return result;
    it = vpi_iterate(vpiParameter, spec);
    while (it && (h = vpi_scan(it))) {
        const char *name = vpi_get_str(vpiName, h);
        if (name && strcmp(name, "ID") == 0) {
            s_vpi_value value;
            memset(&value, 0, sizeof value);
            value.format = vpiIntVal;
            vpi_get_value(h, &value);
            result = (int)value.value.integer;
        }
    }
    return result;
}

static void report(const char *label, vpiHandle spec, vpiHandle other)
{
    vpiHandle it, h, vif = NULL, back;
    int count = 0, named = 0;
    if (!spec) {
        vpi_printf((PLI_BYTE8 *)"%s: no specialization\n", label);
        return;
    }
    it = vpi_iterate(vpiVirtualInterfaceVar, spec);
    while (it && (h = vpi_scan(it))) {
        const char *name = vpi_get_str(vpiName, h);
        ++count;
        if (name && strcmp(name, "vif") == 0) {
            ++named;
            vif = h;
        }
    }
    if (!vif) {
        vpi_printf((PLI_BYTE8 *)"%s: no vif declaration\n", label);
        return;
    }
    back = vpi_handle(vpiClassTypespec, vif);
    vpi_printf((PLI_BYTE8 *)"%s: declarations %d, named vif %d, virtual interface var %d, "
               "owner class typespec %d, own %d, other %d, ID %d\n", label,
               count, named, vpi_get(vpiType, vif) == vpiVirtualInterfaceVar,
               back && vpi_get(vpiType, back) == vpiClassTypespec,
               same(back, spec), same(back, other), parameter_id(back));
}

static PLI_INT32 calltf(PLI_BYTE8 *user_data)
{
    vpiHandle spec3 = specification("owner3");
    vpiHandle spec8 = specification("owner8");
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"specializations distinct %d\n", spec3 && spec8 && !same(spec3, spec8));
    report("owner3", spec3, spec8);
    report("owner8", spec8, spec3);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_vif_owner";
    d.calltf = calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
