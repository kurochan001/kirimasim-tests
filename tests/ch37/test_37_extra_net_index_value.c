/* VPI application of test_37_extra_net_index_value (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_37_extra_net_index_value"

/* The binary value of an object, printed without a stored buffer. */
static void print_value(const char *label, vpiHandle h)
{
    s_vpi_value v;

    memset(&v, 0, sizeof v);
    v.format = vpiBinStrVal;
    vpi_get_value(h, &v);
    vpi_printf((PLI_BYTE8 *)"%s: %s\n", label,
               v.value.str != NULL ? v.value.str : "NULL");
}

/* Write a 4-bit binary value to h with no delay. */
static void put_value(vpiHandle h, const char *bits)
{
    s_vpi_value v;

    memset(&v, 0, sizeof v);
    v.format = vpiBinStrVal;
    v.value.str = (PLI_BYTE8 *)bits;
    vpi_put_value(h, &v, NULL, vpiNoDelay);
}

static PLI_INT32 net_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle na, element, vec, bit;
    s_vpi_delay delay;

    (void)user_data;
    na = vpi_handle_by_name((PLI_BYTE8 *)TOP ".na", NULL);
    vec = vpi_handle_by_name((PLI_BYTE8 *)TOP ".vec", NULL);
    if (na == NULL || vec == NULL) {
        vpi_printf((PLI_BYTE8 *)"missing net\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"net array size: %d\n", (int)vpi_get(vpiSize, na));

    element = vpi_handle_by_index(na, 1);
    vpi_printf((PLI_BYTE8 *)"element 1 size: %d\n",
               element != NULL ? (int)vpi_get(vpiSize, element) : -1);
    print_value("element 1 value", element);

    element = vpi_handle_by_index(na, 0);
    put_value(element, "0011");
    print_value("element 0 after put 0011", element);

    bit = vpi_handle_by_index(vec, 3);
    vpi_printf((PLI_BYTE8 *)"bit 3 size: %d\n",
               bit != NULL ? (int)vpi_get(vpiSize, bit) : -1);
    print_value("bit 3 value", bit);
    put_value(bit, "0");
    print_value("bit 3 after put 0", bit);

    memset(&delay, 0, sizeof delay);
    delay.time_type = vpiScaledRealTime;
    vpi_get_delays(vec, &delay);
    vpi_printf((PLI_BYTE8 *)"delays of the vector net: %d\n",
               (int)delay.no_of_delays);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_net";
    d.calltf = net_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
