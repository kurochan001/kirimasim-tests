/* VPI application of test_vpi_put_array_raw (IEEE 1800-2023 38.35). */
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

#define TOP "test_vpi_put_array_raw"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void layout(void)
{
    s_vpi_arrayvalue v;

    vpi_printf("format PLI_UINT32 %d\n", SAME_TYPE(v.format, PLI_UINT32));
    vpi_printf("flags PLI_UINT32 %d\n", SAME_TYPE(v.flags, PLI_UINT32));
    vpi_printf("integers PLI_INT32 * %d\n", SAME_TYPE(v.value.integers, PLI_INT32 *));
    vpi_printf("shortints PLI_INT16 * %d\n", SAME_TYPE(v.value.shortints, PLI_INT16 *));
    vpi_printf("longints PLI_INT64 * %d\n", SAME_TYPE(v.value.longints, PLI_INT64 *));
    vpi_printf("rawvals PLI_BYTE8 * %d\n", SAME_TYPE(v.value.rawvals, PLI_BYTE8 *));
    vpi_printf("vectors s_vpi_vecval * %d\n",
               SAME_TYPE(v.value.vectors, s_vpi_vecval *));
    vpi_printf("times s_vpi_time * %d\n", SAME_TYPE(v.value.times, s_vpi_time *));
    vpi_printf("reals double * %d\n", SAME_TYPE(v.value.reals, double *));
    vpi_printf("shortreals float * %d\n", SAME_TYPE(v.value.shortreals, float *));
    vpi_printf("vpi_put_value_array returns void %d\n",
               SAME_TYPE(&vpi_put_value_array,
                         void (*)(vpiHandle, p_vpi_arrayvalue, PLI_INT32 *, PLI_UINT32)));
}

static void put(const char *name, s_vpi_arrayvalue *v, PLI_INT32 start, PLI_UINT32 num)
{
    vpiHandle array = by_name(name);
    PLI_INT32 index[1];

    if (array == NULL) {
        vpi_printf("%s not found\n", name);
        return;
    }
    index[0] = start;
    vpi_put_value_array(array, v, index, num);
}

static PLI_INT32 on_start(p_cb_data data)
{
    static PLI_BYTE8 four_state[8] = {(PLI_BYTE8)0xa5, 0x02, (PLI_BYTE8)0xff,
                                      (PLI_BYTE8)0xff, 0x5a, 0x01, (PLI_BYTE8)0xff,
                                      (PLI_BYTE8)0xff};
    static PLI_BYTE8 two_state[4] = {(PLI_BYTE8)0xff, 0x00, 0x00, 0x03};
    static s_vpi_vecval vectors[4];
    static PLI_INT16 shorts[3] = {-5, 7, 300};
    static PLI_INT64 longs[2] = {1234567890123LL, 42};
    s_vpi_arrayvalue v;

    (void)data;
    layout();

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiRawFourStateVal;
    v.value.rawvals = four_state;
    put("b", &v, 0, 2);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiRawTwoStateVal;
    v.value.rawvals = two_state;
    put("l", &v, 0, 2);

    memset(&v, 0, sizeof v);
    memset(vectors, 0, sizeof vectors);
    vectors[0].aval = 0xabcdef12u;
    vectors[1].aval = 0x89u;
    vectors[2].aval = 0x13u;
    v.format = (PLI_UINT32)vpiVectorVal;
    v.value.vectors = vectors;
    put("lv", &v, 0, 2);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiShortIntVal;
    v.value.shortints = shorts;
    put("si", &v, 0, 3);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiLongIntVal;
    v.value.longints = longs;
    put("la", &v, 0, 2);

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
