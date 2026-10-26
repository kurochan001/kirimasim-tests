/* VPI application of test_vpi_release_remove_signatures (IEEE 1800-2023 38.38, 38.39). */
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

#define TOP "test_vpi_release_remove_signatures"

static vpiHandle r_handle, cb_handle;
static int callbacks;

static PLI_INT32 on_change(p_cb_data cb)
{
    callbacks++;
    vpi_printf("%d: r changed to %d\n", (int)cb->time->low,
               cb->value != NULL ? (int)cb->value->value.integer : -1);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time when;
    static s_vpi_value value;
    s_cb_data cb;

    (void)data;
    r_handle = vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL);
    if (r_handle == NULL) {
        vpi_printf("r not found\n");
        return 0;
    }
    memset(&cb, 0, sizeof cb);
    when.type = vpiSimTime;
    value.format = vpiIntVal;
    cb.reason = cbValueChange;
    cb.cb_rtn = on_change;
    cb.obj = r_handle;
    cb.time = &when;
    cb.value = &value;
    cb_handle = vpi_register_cb(&cb);
    return 0;
}

static PLI_INT32 at_two(p_cb_data data)
{
    PLI_INT32 removed, released;

    (void)data;
    removed = vpi_remove_cb(cb_handle);
    vpi_printf("vpi_remove_cb returns PLI_INT32 %d, result %d\n",
               SAME_TYPE(removed, PLI_INT32), (int)removed);
    released = vpi_release_handle(r_handle);
    vpi_printf("vpi_release_handle returns PLI_INT32 %d, result %d\n",
               SAME_TYPE(released, PLI_INT32), (int)released);
    return 0;
}

static PLI_INT32 at_four(p_cb_data data)
{
    (void)data;
    vpi_printf("callbacks after the removal: %d\n", callbacks);
    return 0;
}

static void after(PLI_UINT32 delay, PLI_INT32 (*rtn)(p_cb_data))
{
    static s_vpi_time times[2];
    static int used;
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    times[used].type = vpiSimTime;
    times[used].high = 0;
    times[used].low = delay;
    cb.reason = cbAfterDelay;
    cb.cb_rtn = rtn;
    cb.time = &times[used++];
    vpi_register_cb(&cb);
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
    after(2, at_two);
    after(4, at_four);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
