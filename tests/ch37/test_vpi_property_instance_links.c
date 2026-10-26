/* VPI application of test_vpi_property_instance_links (37.51, 37.52, 37.56). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_property_instance_links"

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

static vpiHandle decl(PLI_INT32 type, const char *name)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = vpi_iterate(type, top), h;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, h), name) == 0) {
            vpi_release_handle(it);
            return h;
        }
    return NULL;
}

static PLI_INT32 props_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle as, prop, dc, rst, pd, spec, e, cb, as4;

    (void)user_data;
    as = by_name("a2");
    prop = as != NULL ? vpi_handle(vpiProperty, as) : NULL;
    dc = prop != NULL ? vpi_handle(vpiDisableCondition, prop) : NULL;
    rst = by_name("rst");
    vpi_printf((PLI_BYTE8 *)"a2 property: disable condition %s, is the rst variable %d\n",
               sprop(vpiName, dc),
               dc != NULL && rst != NULL && vpi_compare_objects(dc, rst));

    pd = decl(vpiPropertyDecl, "p_multi");
    spec = pd != NULL ? vpi_handle(vpiPropertySpec, pd) : NULL;
    e = spec != NULL ? vpi_handle(vpiPropertyExpr, spec) : NULL;
    vpi_printf((PLI_BYTE8 *)"p_multi: property expr multiclock %d\n",
               e != NULL && vpi_get(vpiType, e) == vpiMulticlockSequenceExpr);

    as4 = by_name("a4");
    cb = by_name("cb");
    vpi_printf((PLI_BYTE8 *)"a4: clocking block cb %d\n",
               as4 != NULL && cb != NULL
               && vpi_handle(vpiClockingBlock, as4) != NULL
               && vpi_compare_objects(vpi_handle(vpiClockingBlock, as4), cb));
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
