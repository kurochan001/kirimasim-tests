/* VPI application of test_vpi_put_value_udp_array_errors (IEEE 1800-2023 38.34, 38.35). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_udp_array_errors"

static vpiHandle by_name(const char *name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
}

/* The value put to the UDP instance, with no delay. */
static PLI_INT32 udp_put_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle udp = by_name(TOP ".g");
    s_vpi_value val;

    (void)user_data;
    val.format = vpiScalarVal;
    val.value.scalar = vpi0;
    vpi_put_value(udp, &val, NULL, vpiNoDelay);
    return 0;
}

/* A delay mode other than vpiNoDelay on the UDP instance. */
static PLI_INT32 udp_error_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle udp = by_name(TOP ".g");
    s_vpi_value val;
    s_vpi_time at;

    (void)user_data;
    val.format = vpiScalarVal;
    val.value.scalar = vpi1;
    at.type = vpiSimTime;
    at.high = 0;
    at.low = 3;
    vpi_put_value(udp, &val, &at, vpiTransportDelay);
    vpi_printf((PLI_BYTE8 *)"a delay mode other than vpiNoDelay reports an error: %d\n",
               vpi_chk_error(NULL) != 0);
    return 0;
}

/* Bulk puts with the allowed flags and the values each one writes. */
static PLI_INT32 array_ok_calltf(PLI_BYTE8 *user_data)
{
    static PLI_INT32 plain[4] = {11, 22, 33, 44};
    static PLI_INT32 later[4] = {8, 9, 10, 11};
    static PLI_INT32 order[4] = {1, 2, 3, 4};
    static PLI_INT32 one[1] = {7};
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    vpiHandle arr = by_name(TOP ".arr");
    s_vpi_arrayvalue v;
    s_vpi_value which;
    PLI_INT32 start[1] = {0};
    int k = 0;

    (void)user_data;
    if (arg != NULL) {
        which.format = vpiIntVal;
        vpi_get_value(arg, &which);
        k = (int)which.value.integer;
        vpi_free_object(it);
    }
    memset(&v, 0, sizeof v);
    v.format = vpiIntVal;
    if (k == 2) {
        v.flags = vpiOneValue;
        v.value.integers = one;
        vpi_put_value_array(arr, &v, start, 4);
    } else if (k == 3) {
        v.value.integers = later;
        vpi_put_value_array(arr, &v, start, 4);
    } else if (k == 1) {
        v.flags = vpiPropagateOff;
        v.value.integers = order;
        vpi_put_value_array(arr, &v, start, 4);
    } else {
        v.value.integers = plain;
        vpi_put_value_array(arr, &v, start, 4);
    }
    return 0;
}

/* Flags and a format that vpi_put_value_array does not support. */
static PLI_INT32 array_error_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle arr = by_name(TOP ".arr");
    s_vpi_arrayvalue v;
    PLI_INT32 values[4] = {5, 6, 7, 8};
    PLI_INT32 start[1] = {0};

    (void)user_data;
    memset(&v, 0, sizeof v);
    v.format = vpiIntVal;
    v.value.integers = values;
    v.flags = vpiInertialDelay;
    vpi_put_value_array(arr, &v, start, 4);
    vpi_printf((PLI_BYTE8 *)"a scheduling flag on the bulk put reports an error: %d\n",
               vpi_chk_error(NULL) != 0);

    v.flags = vpiTransportDelay;
    vpi_put_value_array(arr, &v, start, 4);
    vpi_printf((PLI_BYTE8 *)"another scheduling flag on the bulk put reports an error: %d\n",
               vpi_chk_error(NULL) != 0);

    memset(&v, 0, sizeof v);
    v.format = vpiStringVal;
    v.value.rawvals = (PLI_BYTE8 *)"abc";
    vpi_put_value_array(arr, &v, start, 1);
    vpi_printf((PLI_BYTE8 *)"an unsupported format on the bulk put reports an error: %d\n",
               vpi_chk_error(NULL) != 0);
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
    add_task("$vt_udp_put", udp_put_calltf);
    add_task("$vt_udp_error", udp_error_calltf);
    add_task("$vt_array_ok", array_ok_calltf);
    add_task("$vt_array_errors", array_error_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
