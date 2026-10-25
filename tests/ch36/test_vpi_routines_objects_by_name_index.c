/* VPI application of test_vpi_routines_objects_by_name_index (IEEE 1800-2023 36.11, Table 36-5). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_routines_objects_by_name_index"

static int value_of(vpiHandle obj)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(obj, &v);
    return (int)v.value.integer;
}

static void show_named(const char *label, vpiHandle obj)
{
    char name[96];
    const char *s = obj == NULL ? NULL : vpi_get_str(vpiFullName, obj);
    snprintf(name, sizeof name, "%s", s ? s : "NULL");
    if (obj == NULL)
        vpi_printf("%s: NULL\n", label);
    else
        vpi_printf("%s: %s = %d\n", label, name, value_of(obj));
}

static void show_value(const char *label, vpiHandle obj)
{
    if (obj == NULL)
        vpi_printf("%s: NULL\n", label);
    else
        vpi_printf("%s: value %d\n", label, value_of(obj));
}

static PLI_INT32 at_one(p_cb_data data)
{
    vpiHandle u1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1", NULL);
    vpiHandle vec = vpi_handle_by_name((PLI_BYTE8 *)TOP ".vec", NULL);
    vpiHandle arr = vpi_handle_by_name((PLI_BYTE8 *)TOP ".arr", NULL);
    vpiHandle grid = vpi_handle_by_name((PLI_BYTE8 *)TOP ".grid", NULL);
    PLI_INT32 word12[2] = {1, 2}, word01[2] = {0, 1}, bit2[3] = {1, 2, 2}, bit1[3] = {1, 2, 1};

    (void)data;
    show_named("vpi_handle_by_name of the full name",
               vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1.v", NULL));
    show_named("vpi_handle_by_name of v in u1",
               u1 == NULL ? NULL : vpi_handle_by_name((PLI_BYTE8 *)"v", u1));
    show_value("vpi_handle_by_index of vec, 2", vec ? vpi_handle_by_index(vec, 2) : NULL);
    show_value("vpi_handle_by_index of vec, 3", vec ? vpi_handle_by_index(vec, 3) : NULL);
    show_value("vpi_handle_by_index of arr, 1", arr ? vpi_handle_by_index(arr, 1) : NULL);
    show_value("vpi_handle_by_multi_index of grid, 1 2",
               grid ? vpi_handle_by_multi_index(grid, 2, word12) : NULL);
    show_value("vpi_handle_by_multi_index of grid, 0 1",
               grid ? vpi_handle_by_multi_index(grid, 2, word01) : NULL);
    show_value("vpi_handle_by_multi_index of grid, 1 2 2",
               grid ? vpi_handle_by_multi_index(grid, 3, bit2) : NULL);
    show_value("vpi_handle_by_multi_index of grid, 1 2 1",
               grid ? vpi_handle_by_multi_index(grid, 3, bit1) : NULL);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    s_cb_data d;

    (void)data;
    one.type = vpiSimTime;
    one.high = 0;
    one.low = 1;
    memset(&d, 0, sizeof d);
    d.reason = cbAfterDelay;
    d.cb_rtn = at_one;
    d.time = &one;
    vpi_register_cb(&d);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
