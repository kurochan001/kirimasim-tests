/* VPI application of test_vpi_put_value_illegal_formats (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_illegal_formats"

static int string_to_real_error, strength_to_vector_error, string_to_func_error;

static vpiHandle by_name(const char *name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
}

/* The formats the clause allows set the values: a vector on v and a real on r. */
static PLI_INT32 values_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle r = by_name(TOP ".r");
    vpiHandle v = by_name(TOP ".v");
    s_vpi_value val;
    s_vpi_vecval vec;

    (void)user_data;
    vec.aval = 0x000000a5;
    vec.bval = 0;
    val.format = vpiVectorVal;
    val.value.vector = &vec;
    vpi_put_value(v, &val, NULL, vpiNoDelay);
    val.format = vpiRealVal;
    val.value.real = 2.5;
    vpi_put_value(r, &val, NULL, vpiNoDelay);
    return 0;
}

/* The formats the clause makes illegal, each followed at once by vpi_chk_error. */
static PLI_INT32 illegal_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle r = by_name(TOP ".r");
    vpiHandle v = by_name(TOP ".v");
    s_vpi_value val;
    s_vpi_strengthval strength;

    (void)user_data;
    val.format = vpiStringVal;
    val.value.str = (PLI_BYTE8 *)"1.25";
    vpi_put_value(r, &val, NULL, vpiNoDelay);
    string_to_real_error = vpi_chk_error(NULL) != 0;

    strength.logic = vpi1;
    strength.s0 = vpiStrongDrive;
    strength.s1 = vpiStrongDrive;
    val.format = vpiStrengthVal;
    val.value.strength = &strength;
    vpi_put_value(v, &val, NULL, vpiNoDelay);
    strength_to_vector_error = vpi_chk_error(NULL) != 0;

    vpi_printf((PLI_BYTE8 *)"string value to a real variable reports an error: %d\n",
               string_to_real_error);
    vpi_printf((PLI_BYTE8 *)"strength value to a vector reports an error: %d\n",
               strength_to_vector_error);
    vpi_printf((PLI_BYTE8 *)"string value to a real system function reports an error: %d\n",
               string_to_func_error);
    return 0;
}

/* $vt_realfn(1) returns 3.25; $vt_realfn(0) puts an illegal string instead. */
static PLI_INT32 realfn_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value which, val;

    (void)user_data;
    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    which.format = vpiIntVal;
    vpi_get_value(arg, &which);
    if (which.value.integer != 0) {
        val.format = vpiRealVal;
        val.value.real = 3.25;
        vpi_put_value(call, &val, NULL, vpiNoDelay);
    } else {
        val.format = vpiStringVal;
        val.value.str = (PLI_BYTE8 *)"abc";
        vpi_put_value(call, &val, NULL, vpiNoDelay);
        string_to_func_error = vpi_chk_error(NULL) != 0;
    }
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
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
    s_vpi_systf_data d;

    add_task("$vt_values", values_calltf);
    add_task("$vt_illegal", illegal_calltf);
    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiRealFunc;
    d.tfname = (PLI_BYTE8 *)"$vt_realfn";
    d.calltf = realfn_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
