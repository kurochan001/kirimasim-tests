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

/* vpi_get_str() returns every string in one buffer (38.11), so each string
   printed with others is copied. */
static const char *copy_of(PLI_INT32 prop, vpiHandle h, char *buf, size_t n)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;

    snprintf(buf, n, "%s", s != NULL ? s : "NULL");
    return buf;
}

/* A nettype declaration has a name but no full name (37.23), so it is found
   through the vpiNetTypedef iteration of the instance (37.10 detail 10)
   instead of vpi_handle_by_name(), which needs a full name (38.21). Annex M
   defines no constant for that tag, so the object type is used without it. */
#ifndef vpiNetTypedef
#define vpiNetTypedef vpiNettypeDecl
#endif

static vpiHandle nettype_decl(vpiHandle top, const char *name)
{
    vpiHandle it = top != NULL ? vpi_iterate(vpiNetTypedef, top) : NULL, h, found = NULL;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (found == NULL && strcmp(name_of(h), name) == 0)
            found = h;
    return found;
}

static void report(const char *decl_name, const char *net_name)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle decl = nettype_decl(top, decl_name);
    vpiHandle net = find(net_name);
    vpiHandle ts, nts, inst, with;
    char name[48], ts_name[48], ts_type[48], nts_name[48];

    if (decl == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", decl_name);
        return;
    }
    ts = vpi_handle(vpiTypespec, decl);
    nts = net != NULL ? vpi_handle(vpiTypespec, net) : NULL;
    inst = vpi_handle(vpiInstance, decl);
    with = vpi_handle(vpiWith, decl);
    copy_of(vpiName, decl, name, sizeof name);
    copy_of(vpiName, ts, ts_name, sizeof ts_name);
    copy_of(vpiType, ts, ts_type, sizeof ts_type);
    copy_of(vpiName, nts, nts_name, sizeof nts_name);
    vpi_printf((PLI_BYTE8 *)"%s: name %s, instance top %d, typespec %s (%s), "
               "net typespec %s, with %s",
               decl_name, name,
               inst != NULL && top != NULL && vpi_compare_objects(inst, top) ? 1 : 0,
               ts_name, ts != NULL ? ts_type : "none", nts_name,
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
