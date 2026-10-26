/* VPI application of test_vpi_array_get_formats (IEEE 1800-2023 38.16). */
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

#define TOP "test_vpi_array_get_formats"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void read_ints(const char *label, vpiHandle array, PLI_INT32 first,
                      PLI_INT32 second, PLI_UINT32 num, int user)
{
    s_vpi_arrayvalue v;
    PLI_INT32 index[2];
    static int buffer[8];
    int k;

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    index[0] = first;
    index[1] = second;
    if (user) {
        memset(buffer, 0, sizeof buffer);
        v.flags = vpiUserAllocFlag;
        v.value.integers = buffer;
    }
    vpi_get_value_array(array, &v, index, num);
    if (v.value.integers == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: error\n", label);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (k = 0; k < (int)num; k++)
        vpi_printf((PLI_BYTE8 *)" %d", (int)v.value.integers[k]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 on_start(p_cb_data cb)
{
    vpiHandle m = by_name("m"), wa = by_name("wa");
    s_vpi_arrayvalue v;
    PLI_INT32 index[2];
    int copy[2];
    s_vpi_vecval words[4];
    int k;

    (void)cb;
    if (m == NULL || wa == NULL) {
        vpi_printf((PLI_BYTE8 *)"an array is missing\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"shortreals is a float pointer %d\n",
               SAME_TYPE(v.value.shortreals, float *));

    read_ints("m {1,4} x3", m, 1, 4, 3, 0);
    read_ints("m {1,4} x4", m, 1, 4, 4, 0);

    /* Keep a copy of VPI's storage, read another array, and print the copy. */
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    index[0] = 1;
    index[1] = 4;
    vpi_get_value_array(m, &v, index, 2);
    if (v.value.integers != NULL) {
        copy[0] = (int)v.value.integers[0];
        copy[1] = (int)v.value.integers[1];
    } else {
        copy[0] = copy[1] = -1;
    }
    vpi_printf((PLI_BYTE8 *)"copy kept: %d %d\n", copy[0], copy[1]);

    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiVectorVal;
    index[0] = 0;
    vpi_get_value_array(wa, &v, index, 2);
    if (v.value.vectors == NULL) {
        vpi_printf((PLI_BYTE8 *)"wa vectors: error\n");
    } else {
        for (k = 0; k < 4; k++)
            words[k] = v.value.vectors[k];
        vpi_printf((PLI_BYTE8 *)"wa vectors: %08x/%08x %08x/%08x %08x/%08x %08x/%08x\n",
                   (unsigned)words[0].aval, (unsigned)words[0].bval,
                   (unsigned)words[1].aval, (unsigned)words[1].bval,
                   (unsigned)words[2].aval, (unsigned)words[2].bval,
                   (unsigned)words[3].aval, (unsigned)words[3].bval);
    }

    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    static s_vpi_time when;

    when.type = vpiSimTime;
    when.high = 0;
    when.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_start;
    cb.time = &when;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = { register_all, 0 };

#ifdef __cplusplus
}
#endif
