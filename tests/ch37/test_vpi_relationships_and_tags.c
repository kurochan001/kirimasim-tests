/* VPI application of test_vpi_relationships_and_tags (IEEE 1800-2023 37.3.1, 37.22). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_relationships_and_tags"

static vpiHandle find(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 walk_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle bus = find("c.bus"), mod, it, ca;
    s_vpi_value v;

    (void)user_data;
    if (bus == NULL) {
        vpi_printf((PLI_BYTE8 *)"bus not found\n");
        return 0;
    }
    mod = vpi_handle(vpiModule, bus);
    vpi_printf((PLI_BYTE8 *)"bus is in %s, size %d\n",
               mod ? vpi_get_str(vpiFullName, mod) : "no module", (int)vpi_get(vpiSize, bus));
    it = mod ? vpi_iterate(vpiContAssign, mod) : NULL;
    while (it != NULL && (ca = vpi_scan(it)) != NULL) {
        vpiHandle lhs = vpi_handle(vpiLhs, ca), rhs = vpi_handle(vpiRhs, ca), l, r, p;
        if (lhs == NULL || strcmp(name_of(lhs), "y") != 0 || rhs == NULL)
            continue;
        l = vpi_handle(vpiLeftRange, rhs);
        r = vpi_handle(vpiRightRange, rhs);
        p = vpi_handle(vpiParent, rhs);
        v.format = vpiBinStrVal;
        vpi_get_value(rhs, &v);
        vpi_printf((PLI_BYTE8 *)"y = %s of %s, left %d, right %d, value %s\n",
                   vpi_get(vpiType, rhs) == vpiPartSelect ? "part-select" : "other expression",
                   name_of(p), l ? int_value(l) : -1, r ? int_value(r) : -1, v.value.str);
    }
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_walk", walk_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
