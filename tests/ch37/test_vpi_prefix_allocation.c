/* VPI application of test_vpi_prefix_allocation (IEEE 1800-2023 37.61). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char *kind_of(vpiHandle h)
{
    if (h == NULL)
        return "NULL";
    switch (vpi_get(vpiType, h)) {
    case vpiClassVar: return "class var";
    case vpiVirtualInterfaceVar: return "virtual interface var";
    case vpiIntVar: return "int var";
    case vpiReg: return "logic var";
    default: {
        const char *s = vpi_get_str(vpiType, h);
        return s != NULL ? s : "other";
    }
    }
}

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "NULL";
}

static const char *scheme_of(vpiHandle h)
{
    switch ((int)vpi_get(vpiAllocScheme, h)) {
    case vpiAutomaticScheme: return "automatic";
    case vpiDynamicScheme: return "dynamic";
    case vpiOtherScheme: return "other";
    default: return "invalid";
    }
}

static PLI_INT32 prefix_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = call != NULL ? vpi_iterate(vpiArgument, call) : NULL, arg;

    (void)user_data;
    while (it != NULL && (arg = vpi_scan(it)) != NULL) {
        vpiHandle p = vpi_handle(vpiPrefix, arg);
        char kind[48], name[48], prefix_kind[48];

        /* vpi_get_str() returns every string in one buffer (38.11), so each
           string printed with others is copied first. */
        snprintf(kind, sizeof kind, "%s", kind_of(arg));
        snprintf(name, sizeof name, "%s", name_of(arg));
        snprintf(prefix_kind, sizeof prefix_kind, "%s", kind_of(p));
        vpi_printf((PLI_BYTE8 *)"%s %s: prefix %s %s, scheme %s vs %s, same %d\n",
                   kind, name, prefix_kind, name_of(p),
                   scheme_of(arg), scheme_of(p),
                   p != NULL && vpi_get(vpiAllocScheme, arg) == vpi_get(vpiAllocScheme, p)
                       ? 1 : 0);
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_prefix";
    d.calltf = prefix_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
