/* VPI application of test_vpi_put_array_target (IEEE 1800-2023 38.35). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_array_target"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void put(const char *name, s_vpi_arrayvalue *v, PLI_UINT32 num)
{
    vpiHandle array = by_name(name);
    PLI_INT32 index[1];

    if (array == NULL) {
        vpi_printf("%s not found\n", name);
        return;
    }
    index[0] = 0;
    vpi_put_value_array(array, v, index, num);
}

static PLI_INT32 on_start(p_cb_data data)
{
    static PLI_INT32 ints[2] = {10, 20};
    static PLI_INT16 shorts[2] = {-3, 4};
    static PLI_INT64 longs[2] = {42, -5};
    static PLI_BYTE8 bits[2] = {0x11, 0x22};
    static PLI_BYTE8 four_state[4] = {0x33, 0x00, 0x44, 0x00};
    s_vpi_arrayvalue v;

    (void)data;
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    v.value.integers = ints;
    put("ia", &v, 2);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiShortIntVal;
    v.value.shortints = shorts;
    put("sa", &v, 2);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiLongIntVal;
    v.value.longints = longs;
    put("la", &v, 2);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiRawTwoStateVal;
    v.value.rawvals = bits;
    put("ba", &v, 2);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiRawFourStateVal;
    v.value.rawvals = four_state;
    put("lga", &v, 2);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
