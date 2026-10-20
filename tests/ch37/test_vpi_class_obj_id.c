/* VPI application of test_vpi_class_obj_id (IEEE 1800-2023 37.33, 37.32). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_class_obj_id"

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

static PLI_INT32 ids_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle a = find("a"), b = find("b"), c = find("c"), n = find("n");
    PLI_INT32 ia, ib, ic, in;

    (void)user_data;
    if (a == NULL || b == NULL || c == NULL || n == NULL) {
        vpi_printf((PLI_BYTE8 *)"a class variable was not found\n");
        return 0;
    }
    ia = vpi_get(vpiObjId, a);
    ib = vpi_get(vpiObjId, b);
    ic = vpi_get(vpiObjId, c);
    in = vpi_get(vpiObjId, n);
    vpi_printf((PLI_BYTE8 *)"a and b: same %d, nonzero %d; c differs %d; n is 0: %d\n",
               ia == ib, ia != 0, ic != ia && ic != 0, in == 0);
    vpi_printf((PLI_BYTE8 *)"class obj of n: %s, of a: %s; typespec of a: %s\n",
               vpi_handle(vpiClassObj, n) ? "given" : "none",
               vpi_handle(vpiClassObj, a) ? "given" : "none",
               name_of(vpi_handle(vpiClassTypespec, a)));
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
    add("$vt_ids", ids_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
