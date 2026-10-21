/* VPI application of test_vpi_io_decl_ref_objs (IEEE 1800-2023 37.13,
 * 37.15). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_io_decl_ref_objs"
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

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

/* The ref obj that is the expression of an io decl, with its actual. */
static void ref_obj(vpiHandle decl)
{
    vpiHandle ref = vpi_handle(vpiExpr, decl), actual;
    PLI_INT32 type;

    vpi_printf((PLI_BYTE8 *)"expr ref obj %d", ref != NULL && vpi_get(vpiType, ref) == vpiRefObj);
    if (ref == NULL || vpi_get(vpiType, ref) != vpiRefObj) {
        vpi_printf((PLI_BYTE8 *)"\n");
        return;
    }
    actual = vpi_handle(vpiActual, ref);
    type = actual ? vpi_get(vpiType, actual) : 0;
    if (type == vpiInterface || type == vpiModport) {
        vpi_printf((PLI_BYTE8 *)", actual %s %s, def name %s",
                   type == vpiInterface ? "interface" : "modport",
                   type == vpiInterface ? str(vpiFullName, actual) : str(vpiName, actual),
                   str(vpiDefName, ref));
        if (type == vpiInterface)
            vpi_printf((PLI_BYTE8 *)", generic %d", (int)vpi_get(vpiGeneric, ref));
        vpi_printf((PLI_BYTE8 *)", typespec NULL %d\n", vpi_handle(vpiTypespec, ref) == NULL);
    } else if (actual != NULL) {
        vpi_printf((PLI_BYTE8 *)", actual %s = %d\n", str(vpiFullName, actual), int_value(actual));
    } else {
        vpi_printf((PLI_BYTE8 *)", no actual\n");
    }
}

static void io_decls(vpiHandle u)
{
    struct named list[MAX];
    vpiHandle it = vpi_iterate(vpiIODecl, u), h, e;
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        snprintf(list[n].name, sizeof list[n].name, "%s", str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, (size_t)n, sizeof list[0], by_name);
    for (i = 0; i < n; i++) {
        h = list[i].h;
        vpi_printf((PLI_BYTE8 *)"%s: ", list[i].name);
        if (strcmp(list[i].name, "a") == 0) {
            e = vpi_handle(vpiExpr, h);
            vpi_printf((PLI_BYTE8 *)"input %d, size %d, range %d:%d, expr is a net %d\n",
                       vpi_get(vpiDirection, h) == vpiInput, (int)vpi_get(vpiSize, h),
                       int_value(vpi_handle(vpiLeftRange, h)),
                       int_value(vpi_handle(vpiRightRange, h)),
                       e != NULL && vpi_get(vpiType, e) == vpiNet);
        } else {
            if (strcmp(list[i].name, "link") == 0)
                vpi_printf((PLI_BYTE8 *)"ref %d, ", vpi_get(vpiDirection, h) == vpiRef);
            ref_obj(h);
        }
    }
}

/* The target of the assignment in the initial procedure of u. */
static void bit_target(vpiHandle u)
{
    vpiHandle it = vpi_iterate(vpiProcess, u), proc, stmt, lhs, parent, actual;

    proc = it ? vpi_scan(it) : NULL;
    if (proc != NULL)
        vpi_release_handle(it);
    stmt = proc ? vpi_handle(vpiStmt, proc) : NULL;
    lhs = stmt ? vpi_handle(vpiLhs, stmt) : NULL;
    if (lhs == NULL) {
        vpi_printf((PLI_BYTE8 *)"link[4]: target not found\n");
        return;
    }
    parent = vpi_handle(vpiParent, lhs);
    actual = vpi_handle(vpiActual, lhs);
    vpi_printf((PLI_BYTE8 *)"link[4]: ref obj %d, parent is ref obj %s %d, actual %s, var bit %d\n",
               vpi_get(vpiType, lhs) == vpiRefObj, str(vpiName, parent),
               parent != NULL && vpi_get(vpiType, parent) == vpiRefObj, str(vpiFullName, actual),
               actual != NULL && vpi_get(vpiType, actual) == vpiVarBit);
}

static PLI_INT32 io_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle u = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);

    (void)user_data;
    if (u == NULL) {
        vpi_printf((PLI_BYTE8 *)"u: not found\n");
        return 0;
    }
    io_decls(u);
    bit_target(u);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_io";
    d.calltf = io_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
