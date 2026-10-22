/* VPI application of test_vpi_task_function_properties (IEEE 1800-2023
 * 37.41, 37.13), with the C functions that the design imports. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_task_function_properties"
#define MAX 8

struct named {
    char name[16];
    vpiHandle h;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct named *)a)->name, ((const struct named *)b)->name);
}

static const char *str(PLI_INT32 prop, vpiHandle h)
{
    PLI_BYTE8 *s = h ? vpi_get_str(prop, h) : NULL;
    return s ? s : "(null)";
}

static const char *visibility(vpiHandle h)
{
    switch (vpi_get(vpiVisibility, h)) {
    case vpiPublicVis: return "public";
    case vpiProtectedVis: return "protected";
    case vpiLocalVis: return "local";
    default: return "other";
    }
}

static vpiHandle find(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* The first object of a relation whose vpiName is name. */
static vpiHandle member(PLI_INT32 type, vpiHandle ref, const char *name)
{
    vpiHandle it = ref ? vpi_iterate(type, ref) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (found == NULL && strcmp(str(vpiName, h), name) == 0)
            found = h;
    return found;
}

static void returns(void)
{
    vpiHandle f = find("make_pair"), ret, ts;

    if (f != NULL) {
        char rname[64], tname[64];
        ret = vpi_handle(vpiReturn, f);
        ts = ret ? vpi_handle(vpiTypespec, ret) : NULL;
        snprintf(rname, sizeof rname, "%s", str(vpiName, ret));
        snprintf(tname, sizeof tname, "%s", str(vpiName, ts));
        vpi_printf((PLI_BYTE8 *)"function make_pair: visibility %s, method %d, return variable "
                                "%s, struct var %d, typespec %s\n",
                   visibility(f), (int)vpi_get(vpiMethod, f), rname,
                   ret != NULL && vpi_get(vpiType, ret) == vpiStructVar, tname);
    } else {
        vpi_printf((PLI_BYTE8 *)"function make_pair: not found\n");
    }
    f = find("nib");
    if (f != NULL) {
        ret = vpi_handle(vpiReturn, f);
        vpi_printf((PLI_BYTE8 *)"function nib: visibility %s, method %d, return variable %s, "
                                "bit var %d, size %d\n",
                   visibility(f), (int)vpi_get(vpiMethod, f), str(vpiName, ret),
                   ret != NULL && vpi_get(vpiType, ret) == vpiBitVar,
                   ret ? (int)vpi_get(vpiSize, ret) : -1);
    } else {
        vpi_printf((PLI_BYTE8 *)"function nib: not found\n");
    }
}

static void methods(void)
{
    vpiHandle cls = member(vpiClassDefn, vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), "counter");
    vpiHandle it, h;
    struct named list[MAX];
    int n = 0, i;

    if (cls == NULL) {
        vpi_printf((PLI_BYTE8 *)"class counter: not found\n");
        return;
    }
    vpi_printf((PLI_BYTE8 *)"class counter: full name %s\n", str(vpiFullName, cls));
    it = vpi_iterate(vpiMethods, cls);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        snprintf(list[n].name, sizeof list[n].name, "%s", str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, (size_t)n, sizeof list[0], by_name);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"  %s: visibility %s, method %d, virtual %d, full name %s\n",
                   list[i].name, visibility(list[i].h), (int)vpi_get(vpiMethod, list[i].h),
                   (int)vpi_get(vpiVirtual, list[i].h), str(vpiFullName, list[i].h));
}

/* The function that the module imports from the package. */
static void package_function(void)
{
    vpiHandle f = member(vpiImport, vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), "twice");
    vpi_printf((PLI_BYTE8 *)"imported function twice: %s\n", str(vpiFullName, f));
}

static void dpi(void)
{
    vpiHandle h = find("sv_hook");
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"sv_hook: not found\n");
    else
        vpi_printf((PLI_BYTE8 *)"sv_hook: export %d, DPI-C %d, C name %s\n",
                   vpi_get(vpiAccessType, h) == vpiDPIExportAcc,
                   vpi_get(vpiDPICStr, h) == vpiDPIC, str(vpiDPICIdentifier, h));
}

static void ref_argument(void)
{
    vpiHandle decl = member(vpiIODecl, find("bump"), "slot"), e;
    if (decl == NULL) {
        vpi_printf((PLI_BYTE8 *)"bump: io declaration slot not found\n");
        return;
    }
    e = vpi_handle(vpiExpr, decl);
    vpi_printf((PLI_BYTE8 *)"bump: io declaration slot, ref %d, expr ref obj %d\n",
               vpi_get(vpiDirection, decl) == vpiRef,
               e != NULL && vpi_get(vpiType, e) == vpiRefObj);
}

static PLI_INT32 tf_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    returns();
    methods();
    package_function();
    dpi();
    ref_argument();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_tf";
    d.calltf = tf_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
