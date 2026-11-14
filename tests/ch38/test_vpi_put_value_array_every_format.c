/* VPI application of test_vpi_put_value_array_every_format (IEEE 1800-2023 38.35). */
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_array_every_format."

static void put(const char *name, s_vpi_arrayvalue *v)
{
    char full[96];
    vpiHandle array;
    PLI_INT32 index[1] = {0};

    strcpy(full, TOP);
    strcat(full, name);
    array = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (array == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s not found\n", name);
        return;
    }
    vpi_put_value_array(array, v, index, 2);
}

static PLI_INT32 at_1(p_cb_data data)
{
    PLI_INT32 ints[2] = {123456, -7};
    s_vpi_vecval vectors[4] = {
        {0x89abcdefu, 0x00000000u}, {0x00000012u, 0x00000000u},
        {0x000000f0u, 0x000000ffu}, {0x00000000u, 0x00000000u}};
    s_vpi_time times[2];
    double reals[2] = {1.5, -2.25};
    float shortreals[2] = {0.5f, 3.75f};
    PLI_BYTE8 four_state[8] = {(PLI_BYTE8)0xbc, 0x0a, 0x00, 0x00,
                               0x0f, 0x00, (PLI_BYTE8)0xf0, 0x00};
    PLI_BYTE8 two_state[4] = {0x34, 0x02, (PLI_BYTE8)0xff, 0x0f};
    PLI_INT16 shorts[2] = {-300, 1234};
    PLI_INT64 longs[2] = {-5, (PLI_INT64)1 << 40};
    s_vpi_arrayvalue v;

    (void)data;
    memset(&v, 0, sizeof v);
    v.format = vpiIntVal;
    v.value.integers = ints;
    put("ia", &v);

    memset(&v, 0, sizeof v);
    v.format = vpiVectorVal;
    v.value.vectors = vectors;
    put("va", &v);

    memset(times, 0, sizeof times);
    times[0].type = vpiSimTime;
    times[0].high = 0;
    times[0].low = 7;
    times[1].type = vpiSimTime;
    times[1].high = 1;
    times[1].low = 5;
    memset(&v, 0, sizeof v);
    v.format = vpiTimeVal;
    v.value.times = times;
    put("ta", &v);

    memset(&v, 0, sizeof v);
    v.format = vpiRealVal;
    v.value.reals = reals;
    put("ra", &v);

    memset(&v, 0, sizeof v);
    v.format = vpiShortRealVal;
    v.value.shortreals = shortreals;
    put("sra", &v);

    memset(&v, 0, sizeof v);
    v.format = vpiRawFourStateVal;
    v.value.rawvals = four_state;
    put("r4", &v);

    memset(&v, 0, sizeof v);
    v.format = vpiRawTwoStateVal;
    v.value.rawvals = two_state;
    put("r2", &v);

    memset(&v, 0, sizeof v);
    v.format = vpiShortIntVal;
    v.value.shortints = shorts;
    put("sa", &v);

    memset(&v, 0, sizeof v);
    v.format = vpiLongIntVal;
    v.value.longints = longs;
    put("la", &v);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    s_cb_data cb;

    (void)data;
    one.type = vpiSimTime;
    one.high = 0;
    one.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = at_1;
    cb.time = &one;
    vpi_register_cb(&cb);
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
