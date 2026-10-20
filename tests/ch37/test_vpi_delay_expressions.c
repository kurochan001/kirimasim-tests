/* VPI application of test_vpi_delay_expressions (IEEE 1800-2023 37.3.4, 37.75). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_delay_expressions"

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

static void describe(const char *label, vpiHandle d)
{
    vpiHandle it, op;

    if (d == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no delay\n", label);
    } else if (vpi_get(vpiType, d) == vpiOperation && vpi_get(vpiOpType, d) == vpiListOp) {
        vpi_printf((PLI_BYTE8 *)"%s: list of delays", label);
        it = vpi_iterate(vpiOperand, d);
        while (it != NULL && (op = vpi_scan(it)) != NULL)
            vpi_printf((PLI_BYTE8 *)" %d", int_value(op));
        vpi_printf((PLI_BYTE8 *)"\n");
    } else {
        vpi_printf((PLI_BYTE8 *)"%s: %s %d\n", label,
                   vpi_get(vpiType, d) == vpiOperation ? "operation" : "delay", int_value(d));
    }
}

static PLI_INT32 delays_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    const char *names[] = {"g1", "g2"};
    vpiHandle it, h;
    int k;

    (void)user_data;
    for (k = 0; k < 2; k++) {
        vpiHandle found = NULL;
        it = top ? vpi_iterate(vpiPrimitive, top) : NULL;
        while (it != NULL && (h = vpi_scan(it)) != NULL)
            if (strcmp(name_of(h), names[k]) == 0)
                found = h;
        if (found != NULL)
            describe(names[k], vpi_handle(vpiDelay, found));
        else
            vpi_printf((PLI_BYTE8 *)"%s not found\n", names[k]);
    }
    it = top ? vpi_iterate(vpiContAssign, top) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        describe("continuous assignment", vpi_handle(vpiDelay, h));
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
    add("$vt_delays", delays_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
