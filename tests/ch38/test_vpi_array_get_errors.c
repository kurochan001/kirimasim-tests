/* VPI application of test_vpi_array_get_errors (IEEE 1800-2023 38.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T. */
#ifdef __cplusplus
template <typename A, typename B> struct vt_same { enum { value = 0 }; };
template <typename A> struct vt_same<A, A> { enum { value = 1 }; };
#define SAME_TYPE(e, T) ((int)vt_same<decltype(e), T>::value)
#else
#define SAME_TYPE(e, T) _Generic((e), T: 1, default: 0)
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_array_get_errors"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    vpiHandle m = by_name("m"), sr = by_name("sr"), wa = by_name("wa");
    vpiHandle sa = by_name("sa"), da = by_name("da"), ra = by_name("ra"), ta = by_name("ta");
    s_vpi_arrayvalue v;
    PLI_INT32 index[2];
    static float floats[3];
    static int user_ints[2];
    static s_vpi_vecval words[4];
    static int keep[2];
    int k;

    (void)cb;
    if (m == NULL || sr == NULL || wa == NULL || sa == NULL || da == NULL
        || ra == NULL || ta == NULL) {
        vpi_printf((PLI_BYTE8 *)"an array is missing\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"shortreals is a float pointer %d\n",
               SAME_TYPE(v.value.shortreals, float *));

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiShortRealVal;
    index[0] = 0;
    vpi_get_value_array(sr, &v, index, 3);
    if (v.value.shortreals == NULL) {
        vpi_printf((PLI_BYTE8 *)"sr shortreals: error\n");
    } else {
        for (k = 0; k < 3; k++)
            floats[k] = v.value.shortreals[k];
        vpi_printf((PLI_BYTE8 *)"sr shortreals: %.2f %.2f %.2f\n",
                   (double)floats[0], (double)floats[1], (double)floats[2]);
    }

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    v.flags = vpiUserAllocFlag;
    v.value.integers = user_ints;
    index[0] = 1;
    index[1] = 4;
    vpi_get_value_array(m, &v, index, 2);
    vpi_printf((PLI_BYTE8 *)"user ints: %d %d\n", (int)user_ints[0], (int)user_ints[1]);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiRealVal;
    index[0] = 0;
    vpi_get_value_array(ra, &v, index, 2);
    vpi_printf((PLI_BYTE8 *)"reals: %.2f %.2f\n", v.value.reals[0], v.value.reals[1]);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiTimeVal;
    index[0] = 0;
    vpi_get_value_array(ta, &v, index, 2);
    vpi_printf((PLI_BYTE8 *)"times: %u %u\n", (unsigned)v.value.times[0].low,
               (unsigned)v.value.times[1].low);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiVectorVal;
    index[0] = 0;
    vpi_get_value_array(wa, &v, index, 2);
    for (k = 0; k < 4; k++)
        words[k] = v.value.vectors[k];
    vpi_printf((PLI_BYTE8 *)"vectors: %08x/%08x %08x/%08x %08x/%08x %08x/%08x\n",
               (unsigned)words[0].aval, (unsigned)words[0].bval,
               (unsigned)words[1].aval, (unsigned)words[1].bval,
               (unsigned)words[2].aval, (unsigned)words[2].bval,
               (unsigned)words[3].aval, (unsigned)words[3].bval);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiStringVal;
    index[0] = 1;
    index[1] = 4;
    vpi_get_value_array(m, &v, index, 1);
    vpi_printf((PLI_BYTE8 *)"an unlisted format on an int array: null %d\n",
               v.value.rawvals == NULL);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiRealVal;
    index[0] = 1;
    index[1] = 4;
    vpi_get_value_array(m, &v, index, 1);
    vpi_printf((PLI_BYTE8 *)"a real format on an int array: null %d\n",
               v.value.reals == NULL);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiShortRealVal;
    index[0] = 1;
    index[1] = 4;
    vpi_get_value_array(m, &v, index, 1);
    vpi_printf((PLI_BYTE8 *)"a shortreal format on an int array: null %d\n",
               v.value.shortreals == NULL);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    index[0] = 0;
    vpi_get_value_array(sa, &v, index, 1);
    vpi_printf((PLI_BYTE8 *)"an array with string elements: null %d\n",
               v.value.integers == NULL);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    index[0] = 0;
    vpi_get_value_array(da, &v, index, 1);
    vpi_printf((PLI_BYTE8 *)"a dynamic array: null %d\n", v.value.integers == NULL);

    keep[0] = 55;
    keep[1] = 77;
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    v.value.integers = keep;
    index[0] = 0;
    vpi_get_value_array(sa, &v, index, 1);
    vpi_printf((PLI_BYTE8 *)"the error sets the pointer to NULL %d, the kept buffer has %d\n",
               v.value.integers == NULL, keep[1]);
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
