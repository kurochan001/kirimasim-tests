/* VPI application of test_vpi_put_value_array_formats (IEEE 1800-2023 38.35). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void put(const char *name, s_vpi_arrayvalue *av, PLI_INT32 first, PLI_UINT32 num)
{
    char full[96];
    vpiHandle array;
    PLI_INT32 index[1];

    snprintf(full, sizeof full, "test_vpi_put_value_array_formats.%s", name);
    array = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (array == NULL) {
        vpi_printf("%s not found\n", name);
        return;
    }
    index[0] = first;
    vpi_put_value_array(array, av, index, num);
}

static PLI_INT32 on_start(p_cb_data data)
{
    /* 12-bit elements: 2 bytes each, least significant first */
    static PLI_BYTE8 two_state[6] = {0x34, 0x02, (PLI_BYTE8)0xff, 0x0f, 0x01, 0x08};
    /* 10-bit elements: 2 bytes of aval, then 2 bytes of bval */
    static PLI_BYTE8 four_state[8] = {0x55, 0x03, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00};
    static s_vpi_vecval vectors[4];
    static PLI_INT16 shorts[3] = {-5, 7, 300};
    static PLI_INT64 longs[2];
    s_vpi_arrayvalue av;

    (void)data;
    memset(vectors, 0, sizeof vectors);
    vectors[0].aval = 0x89abcdef;
    vectors[1].aval = 0x12;
    vectors[2].aval = 0x1;
    vectors[3].aval = 0xff;
    longs[0] = -1234567890123LL;
    longs[1] = 42;

    memset(&av, 0, sizeof av);
    av.format = vpiRawTwoStateVal;
    av.value.rawvals = two_state;
    put("bv", &av, 0, 3);

    memset(&av, 0, sizeof av);
    av.format = vpiRawFourStateVal;
    av.value.rawvals = four_state;
    put("fv", &av, 0, 2);

    memset(&av, 0, sizeof av);
    av.format = vpiVectorVal;
    av.value.vectors = vectors;
    put("lv", &av, 1, 2);

    memset(&av, 0, sizeof av);
    av.format = vpiShortIntVal;
    av.value.shortints = shorts;
    put("si", &av, 1, 3);

    memset(&av, 0, sizeof av);
    av.format = vpiLongIntVal;
    av.value.longints = longs;
    put("li", &av, 0, 2);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
