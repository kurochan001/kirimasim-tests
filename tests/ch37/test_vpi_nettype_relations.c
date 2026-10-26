/* VPI application of test_vpi_nettype_relations (IEEE 1800-2023 37.23, 37.10). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_nettype_relations"

static vpiHandle find(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "NULL";
}

static void report(const char *decl_name, const char *net_name)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle decl = find(decl_name);
    vpiHandle net = find(net_name);
    vpiHandle ts, nts, inst, with;

    if (decl == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", decl_name);
        return;
    }
    ts = vpi_handle(vpiTypespec, decl);
    nts = net != NULL ? vpi_handle(vpiTypespec, net) : NULL;
    inst = vpi_handle(vpiInstance, decl);
    with = vpi_handle(vpiWith, decl);
    vpi_printf((PLI_BYTE8 *)"%s: name %s, instance top %d, typespec %s (%s), "
               "net typespec %s, with %s",
               decl_name, name_of(decl),
               inst != NULL && top != NULL && vpi_compare_objects(inst, top) ? 1 : 0,
               name_of(ts), ts != NULL ? vpi_get_str(vpiType, ts) : "none",
               name_of(nts),
               with != NULL ? name_of(with) : "NULL");
    if (with != NULL)
        vpi_printf((PLI_BYTE8 *)" (%s)", vpi_get_str(vpiType, with));
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 nettype_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    report("nt_plain", "p");
    report("nt_res", "r");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_nettype";
    d.calltf = nettype_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
