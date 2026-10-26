/* VPI application of test_vpi_array_put_formats (IEEE 1800-2023 38.35). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_array_put_formats"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    vpiHandle fsr = by_name("fsr"), fr = by_name("fr"), ft = by_name("ft");
    vpiHandle m = by_name("m"), w = by_name("w");
    s_vpi_arrayvalue v;
    PLI_INT32 index[2];
    float floats[3] = { 1.5f, 2.5f, 3.5f };
    double reals[2] = { -4.5, 6.25 };
    s_vpi_time times[2];
    PLI_INT32 ints[2] = { 21, 22 };
    PLI_INT32 one[1] = { 99 };
    s_vpi_vecval words[4];

    (void)cb;
    if (fsr == NULL || fr == NULL || ft == NULL || m == NULL || w == NULL) {
        vpi_printf((PLI_BYTE8 *)"an array is missing\n");
        return 0;
    }

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiShortRealVal;
    v.value.shortreals = floats;
    index[0] = 0;
    vpi_put_value_array(fsr, &v, index, 3);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiRealVal;
    v.value.reals = reals;
    index[0] = 0;
    vpi_put_value_array(fr, &v, index, 2);

    memset(times, 0, sizeof times);
    times[0].type = vpiSimTime;
    times[0].low = 10;
    times[1].type = vpiSimTime;
    times[1].low = 20;
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiTimeVal;
    v.value.times = times;
    index[0] = 0;
    vpi_put_value_array(ft, &v, index, 2);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    v.value.integers = ints;
    index[0] = 2;
    index[1] = 4;
    vpi_put_value_array(m, &v, index, 2);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    v.value.integers = one;
    index[0] = 1;
    index[1] = 5;
    vpi_put_value_array(m, &v, index, 1);

    memset(words, 0, sizeof words);
    words[0].aval = 3;
    words[1].aval = 3;
    words[2].aval = 4;
    words[3].aval = 4;
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiVectorVal;
    v.value.vectors = words;
    index[0] = 0;
    vpi_put_value_array(w, &v, index, 2);
    return 0;
}

static void register_all(void)
{
    static s_vpi_time when;
    s_cb_data cb;

    when.type = vpiSimTime;
    when.high = 0;
    when.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &when;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = { register_all, 0 };

#ifdef __cplusplus
}
#endif
