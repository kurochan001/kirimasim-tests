/* VPI application of test_vpi_attribute_default_bit_and_last_value (IEEE 1800-2023 5.12, 37.83). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_attribute_default_bit_and_last_value"

static const char *const variables[] = {
    "v_flag", "v_one", "v_same", "v_two", "v_to_bit", "v_to_int"
};

/* Prints one attribute: its name, then its value in the format of its type. */
static void show_attribute(const char *var, vpiHandle a)
{
    char name[64];
    const char *s;
    s_vpi_value v;

    s = vpi_get_str(vpiName, a);
    snprintf(name, sizeof name, "%s", s != NULL ? s : "(no name)");
    v.format = vpiObjTypeVal;
    vpi_get_value(a, &v);
    if (v.format == vpiScalarVal)
        vpi_printf((PLI_BYTE8 *)"%s: %s scalar %s\n", var, name,
                   v.value.scalar == vpi1 ? "1" : v.value.scalar == vpi0 ? "0" : "x/z");
    else if (v.format == vpiStrengthVal)
        vpi_printf((PLI_BYTE8 *)"%s: %s scalar %s\n", var, name,
                   v.value.strength->logic == vpi1 ? "1"
                   : v.value.strength->logic == vpi0 ? "0" : "x/z");
    else if (v.format == vpiIntVal)
        vpi_printf((PLI_BYTE8 *)"%s: %s integer %d\n", var, name, (int)v.value.integer);
    else if (v.format == vpiVectorVal)
        vpi_printf((PLI_BYTE8 *)"%s: %s vector aval %x bval %x\n", var, name,
                   (unsigned)v.value.vector[0].aval, (unsigned)v.value.vector[0].bval);
    else
        vpi_printf((PLI_BYTE8 *)"%s: %s format %d\n", var, name, (int)v.format);
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    char path[128];
    vpiHandle h, it, a;
    size_t i;
    int n;

    (void)data;
    for (i = 0; i < sizeof variables / sizeof variables[0]; i++) {
        snprintf(path, sizeof path, "%s.%s", TOP, variables[i]);
        h = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
        if (h == NULL) {
            vpi_printf((PLI_BYTE8 *)"%s: not found\n", variables[i]);
            continue;
        }
        n = 0;
        it = vpi_iterate(vpiAttribute, h);
        while (it != NULL && (a = vpi_scan(it)) != NULL) {
            show_attribute(variables[i], a);
            n++;
        }
        vpi_printf((PLI_BYTE8 *)"%s: %d attribute(s)\n", variables[i], n);
    }
    return 0;
}

static void register_all(void)
{
    s_cb_data d;

    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = start_of_simulation;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
