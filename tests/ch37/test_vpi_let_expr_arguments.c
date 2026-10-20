/* VPI application of test_vpi_let_expr_arguments (IEEE 1800-2023 37.57, 11.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_let_expr_arguments"

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

static PLI_INT32 let_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top ? vpi_iterate(vpiContAssign, top) : NULL, ca, rhs, args, h;

    (void)user_data;
    while (it != NULL && (ca = vpi_scan(it)) != NULL) {
        rhs = vpi_handle(vpiRhs, ca);
        if (rhs == NULL || vpi_get(vpiType, rhs) != vpiLetExpr) {
            vpi_printf((PLI_BYTE8 *)"the right-hand side is not a let expression\n");
            continue;
        }
        vpi_printf((PLI_BYTE8 *)"let expression of %s, arguments:",
                   name_of(vpi_handle(vpiLetDecl, rhs)));
        args = vpi_iterate(vpiArgument, rhs);
        while (args != NULL && (h = vpi_scan(args)) != NULL)
            vpi_printf((PLI_BYTE8 *)" %d", int_value(h));
        vpi_printf((PLI_BYTE8 *)", value %d\n", int_value(rhs));
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
    add("$vt_let", let_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
