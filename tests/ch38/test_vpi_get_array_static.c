/* VPI application of test_vpi_get_array_static (IEEE 1800-2023 38.16). */
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

#define TOP "test_vpi_get_array_static"

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
    vpi_printf("vpi_get_value_array returns void %d\n",
               SAME_TYPE(&vpi_get_value_array,
                         void (*)(vpiHandle, p_vpi_arrayvalue, PLI_INT32 *, PLI_UINT32)));
}

static void raw(const char *what, vpiHandle array, PLI_UINT32 format, PLI_INT32 start,
                PLI_UINT32 num, PLI_UINT32 groups)
{
    s_vpi_arrayvalue v;
    PLI_INT32 index[1];
    PLI_UINT32 bytes = format == (PLI_UINT32)vpiRawFourStateVal ? groups * num * 2
                                                                : groups * num;
    unsigned char copy[64];
    PLI_UINT32 k;

    memset(&v, 0, sizeof v);
    v.format = format;
    index[0] = start;
    vpi_get_value_array(array, &v, index, num);
    if (v.value.rawvals == NULL) {
        vpi_printf("%s: error\n", what);
        return;
    }
    memset(copy, 0, sizeof copy);
    memcpy(copy, v.value.rawvals, bytes);
    vpi_printf("%s:", what);
    for (k = 0; k < bytes; k++)
        vpi_printf(" %02x", copy[k]);
    vpi_printf("\n");
}

static PLI_INT32 on_delay(p_cb_data data)
{
    vpiHandle a = by_name("a"), b = by_name("b"), l = by_name("l");
    vpiHandle ia = by_name("ia"), sa = by_name("sa"), la = by_name("la"), lv = by_name("lv");
    s_vpi_arrayvalue v;
    PLI_INT32 index[1];
    int ints[2];
    short shorts[3];
    PLI_INT64 longs[3];
    s_vpi_vecval words[4];
    int k;

    (void)data;
    if (a == NULL || b == NULL || l == NULL || ia == NULL || sa == NULL || la == NULL
        || lv == NULL) {
        vpi_printf("array not found\n");
        return 0;
    }
    layout();
    raw("a[1:2] raw four-state", a, (PLI_UINT32)vpiRawFourStateVal, 1, 2, 2);
    raw("a[1:2] raw two-state", a, (PLI_UINT32)vpiRawTwoStateVal, 1, 2, 2);
    raw("b[0:1] raw four-state of a 2-state array", b, (PLI_UINT32)vpiRawFourStateVal,
        0, 2, 2);
    raw("l[0:1] raw two-state of a 4-state array", l, (PLI_UINT32)vpiRawTwoStateVal,
        0, 2, 2);
    raw("a[3] raw four-state", a, (PLI_UINT32)vpiRawFourStateVal, 3, 1, 2);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    index[0] = 3;
    vpi_get_value_array(ia, &v, index, 2);
    if (v.value.integers == NULL) {
        vpi_printf("ia[3:4] as integers: error\n");
    } else {
        ints[0] = (int)v.value.integers[0];
        ints[1] = (int)v.value.integers[1];
        vpi_printf("ia[3:4] as integers: %d %d\n", ints[0], ints[1]);
    }

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiShortIntVal;
    index[0] = 0;
    vpi_get_value_array(sa, &v, index, 3);
    if (v.value.shortints == NULL) {
        vpi_printf("sa[0:2] as shortints: error\n");
    } else {
        for (k = 0; k < 3; k++)
            shorts[k] = v.value.shortints[k];
        vpi_printf("sa[0:2] as shortints: %d %d %d\n", (int)shorts[0], (int)shorts[1],
                   (int)shorts[2]);
    }

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiLongIntVal;
    index[0] = 0;
    vpi_get_value_array(la, &v, index, 3);
    if (v.value.longints == NULL) {
        vpi_printf("la[0:2] as longints: error\n");
    } else {
        for (k = 0; k < 3; k++)
            longs[k] = v.value.longints[k];
        vpi_printf("la[0:2] as longints: %lld %lld %lld\n", (long long)longs[0],
                   (long long)longs[1], (long long)longs[2]);
    }

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiVectorVal;
    index[0] = 0;
    vpi_get_value_array(lv, &v, index, 2);
    if (v.value.vectors == NULL) {
        vpi_printf("lv[0:1] as vectors: error\n");
    } else {
        for (k = 0; k < 4; k++)
            words[k] = v.value.vectors[k];
        vpi_printf("lv[0:1] as vectors: %08x %08x %08x %08x %08x %08x %08x %08x\n",
                   (unsigned)words[0].aval, (unsigned)words[0].bval,
                   (unsigned)words[1].aval, (unsigned)words[1].bval,
                   (unsigned)words[2].aval, (unsigned)words[2].bval,
                   (unsigned)words[3].aval, (unsigned)words[3].bval);
    }
    return 0;
}

static void register_all(void)
{
    static s_vpi_time when;
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    when.type = vpiSimTime;
    when.high = 0;
    when.low = 1;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &when;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
