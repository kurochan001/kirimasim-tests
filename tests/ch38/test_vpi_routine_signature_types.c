/* VPI application of test_vpi_routine_signature_types (38.1). */
#include <stdio.h>
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

static PLI_INT32 types_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"vpi_get: %d\n",
               SAME_TYPE(&vpi_get, PLI_INT32 (*)(PLI_INT32, vpiHandle)));
    vpi_printf((PLI_BYTE8 *)"vpi_get64: %d\n",
               SAME_TYPE(&vpi_get64, PLI_INT64 (*)(PLI_INT32, vpiHandle)));
    vpi_printf((PLI_BYTE8 *)"vpi_get_str: %d\n",
               SAME_TYPE(&vpi_get_str, PLI_BYTE8 *(*)(PLI_INT32, vpiHandle)));
    vpi_printf((PLI_BYTE8 *)"vpi_iterate: %d\n",
               SAME_TYPE(&vpi_iterate, vpiHandle (*)(PLI_INT32, vpiHandle)));
    vpi_printf((PLI_BYTE8 *)"vpi_scan: %d\n",
               SAME_TYPE(&vpi_scan, vpiHandle (*)(vpiHandle)));
    vpi_printf((PLI_BYTE8 *)"vpi_free_object: %d\n",
               SAME_TYPE(&vpi_free_object, PLI_INT32 (*)(vpiHandle)));
    vpi_printf((PLI_BYTE8 *)"vpi_release_handle: %d\n",
               SAME_TYPE(&vpi_release_handle, PLI_INT32 (*)(vpiHandle)));
    vpi_printf((PLI_BYTE8 *)"vpi_get_value: %d\n",
               SAME_TYPE(&vpi_get_value, void (*)(vpiHandle, p_vpi_value)));
    vpi_printf((PLI_BYTE8 *)"vpi_put_value: %d\n",
               SAME_TYPE(&vpi_put_value,
                         vpiHandle (*)(vpiHandle, p_vpi_value, p_vpi_time,
                                       PLI_INT32)));
    vpi_printf((PLI_BYTE8 *)"vpi_register_cb: %d\n",
               SAME_TYPE(&vpi_register_cb, vpiHandle (*)(p_cb_data)));
    vpi_printf((PLI_BYTE8 *)"vpi_remove_cb: %d\n",
               SAME_TYPE(&vpi_remove_cb, PLI_INT32 (*)(vpiHandle)));
    vpi_printf((PLI_BYTE8 *)"vpi_control: %d\n",
               SAME_TYPE(&vpi_control, PLI_INT32 (*)(PLI_INT32, ...)));
    vpi_printf((PLI_BYTE8 *)"vpi_printf: %d\n",
               SAME_TYPE(&vpi_printf, PLI_INT32 (*)(PLI_BYTE8 *, ...)));
    vpi_printf((PLI_BYTE8 *)"vpi_put_delays: %d\n",
               SAME_TYPE(&vpi_put_delays,
                         void (*)(vpiHandle, p_vpi_delay)));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_types";
    d.calltf = types_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
