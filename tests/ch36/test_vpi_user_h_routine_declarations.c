/* VPI application of test_vpi_user_h_routine_declarations (IEEE 1800-2023 36.7, K.2). */
#include <string.h>
#include "vpi_user.h"

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T.
   Nothing is called or linked: only the declarations of the header are used. */
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

#define CHECK(what, ok) vpi_printf((PLI_BYTE8 *)"%s %d\n", what, (int)(ok))

static PLI_INT32 check_all(p_cb_data data)
{
    (void)data;
    CHECK("vpi_chk_error: PLI_INT32 (p_vpi_error_info error_info_p)",
          SAME_TYPE(&vpi_chk_error, PLI_INT32 (*)(p_vpi_error_info error_info_p)));
    CHECK("vpi_compare_objects: PLI_INT32 (vpiHandle object1, vpiHandle object2)",
          SAME_TYPE(&vpi_compare_objects, PLI_INT32 (*)(vpiHandle object1, vpiHandle object2)));
    CHECK("vpi_control: PLI_INT32 (PLI_INT32 operation, ...)",
          SAME_TYPE(&vpi_control, PLI_INT32 (*)(PLI_INT32 operation, ...)));
    CHECK("vpi_flush: PLI_INT32 (void)",
          SAME_TYPE(&vpi_flush, PLI_INT32 (*)(void)));
    CHECK("vpi_free_object: PLI_INT32 (vpiHandle object)",
          SAME_TYPE(&vpi_free_object, PLI_INT32 (*)(vpiHandle object)));
    CHECK("vpi_get: PLI_INT32 (PLI_INT32 property, vpiHandle object)",
          SAME_TYPE(&vpi_get, PLI_INT32 (*)(PLI_INT32 property, vpiHandle object)));
    CHECK("vpi_get64: PLI_INT64 (PLI_INT32 property, vpiHandle object)",
          SAME_TYPE(&vpi_get64, PLI_INT64 (*)(PLI_INT32 property, vpiHandle object)));
    CHECK("vpi_get_cb_info: void (vpiHandle object, p_cb_data cb_data_p)",
          SAME_TYPE(&vpi_get_cb_info, void (*)(vpiHandle object, p_cb_data cb_data_p)));
    CHECK("vpi_get_data: PLI_INT32 (PLI_INT32 id, PLI_BYTE8 *dataLoc, PLI_INT32 numOfBytes)",
          SAME_TYPE(&vpi_get_data, PLI_INT32 (*)(PLI_INT32 id, PLI_BYTE8 *dataLoc, PLI_INT32
          numOfBytes)));
    CHECK("vpi_get_delays: void (vpiHandle object, p_vpi_delay delay_p)",
          SAME_TYPE(&vpi_get_delays, void (*)(vpiHandle object, p_vpi_delay delay_p)));
    CHECK("vpi_get_str: PLI_BYTE8 * (PLI_INT32 property, vpiHandle object)",
          SAME_TYPE(&vpi_get_str, PLI_BYTE8 * (*)(PLI_INT32 property, vpiHandle object)));
    CHECK("vpi_get_systf_info: void (vpiHandle object, p_vpi_systf_data systf_data_p)",
          SAME_TYPE(&vpi_get_systf_info, void (*)(vpiHandle object, p_vpi_systf_data
          systf_data_p)));
    CHECK("vpi_get_time: void (vpiHandle object, p_vpi_time time_p)",
          SAME_TYPE(&vpi_get_time, void (*)(vpiHandle object, p_vpi_time time_p)));
    CHECK("vpi_get_userdata: void * (vpiHandle obj)",
          SAME_TYPE(&vpi_get_userdata, void * (*)(vpiHandle obj)));
    CHECK("vpi_get_value: void (vpiHandle expr, p_vpi_value value_p)",
          SAME_TYPE(&vpi_get_value, void (*)(vpiHandle expr, p_vpi_value value_p)));
    CHECK("vpi_get_value_array",
          SAME_TYPE(&vpi_get_value_array, void (*)(vpiHandle object, p_vpi_arrayvalue
          arrayvalue_p, PLI_INT32 *index_p, PLI_UINT32 num)));
    CHECK("vpi_get_vlog_info: PLI_INT32 (p_vpi_vlog_info vlog_info_p)",
          SAME_TYPE(&vpi_get_vlog_info, PLI_INT32 (*)(p_vpi_vlog_info vlog_info_p)));
    CHECK("vpi_handle: vpiHandle (PLI_INT32 type, vpiHandle refHandle)",
          SAME_TYPE(&vpi_handle, vpiHandle (*)(PLI_INT32 type, vpiHandle refHandle)));
    CHECK("vpi_handle_by_index: vpiHandle (vpiHandle object, PLI_INT32 indx)",
          SAME_TYPE(&vpi_handle_by_index, vpiHandle (*)(vpiHandle object, PLI_INT32 indx)));
    CHECK("vpi_handle_by_multi_index",
          SAME_TYPE(&vpi_handle_by_multi_index, vpiHandle (*)(vpiHandle obj, PLI_INT32 num_index,
          PLI_INT32 *index_array)));
    CHECK("vpi_handle_by_name: vpiHandle (PLI_BYTE8 *name, vpiHandle scope)",
          SAME_TYPE(&vpi_handle_by_name, vpiHandle (*)(PLI_BYTE8 *name, vpiHandle scope)));
    CHECK("vpi_handle_multi",
          SAME_TYPE(&vpi_handle_multi, vpiHandle (*)(PLI_INT32 type, vpiHandle refHandle1,
          vpiHandle refHandle2, ...)));
    CHECK("vpi_iterate: vpiHandle (PLI_INT32 type, vpiHandle refHandle)",
          SAME_TYPE(&vpi_iterate, vpiHandle (*)(PLI_INT32 type, vpiHandle refHandle)));
    CHECK("vpi_mcd_close: PLI_UINT32 (PLI_UINT32 mcd)",
          SAME_TYPE(&vpi_mcd_close, PLI_UINT32 (*)(PLI_UINT32 mcd)));
    CHECK("vpi_mcd_flush: PLI_INT32 (PLI_UINT32 mcd)",
          SAME_TYPE(&vpi_mcd_flush, PLI_INT32 (*)(PLI_UINT32 mcd)));
    CHECK("vpi_mcd_name: PLI_BYTE8 * (PLI_UINT32 cd)",
          SAME_TYPE(&vpi_mcd_name, PLI_BYTE8 * (*)(PLI_UINT32 cd)));
    CHECK("vpi_mcd_open: PLI_UINT32 (PLI_BYTE8 *fileName)",
          SAME_TYPE(&vpi_mcd_open, PLI_UINT32 (*)(PLI_BYTE8 *fileName)));
    CHECK("vpi_mcd_printf: PLI_INT32 (PLI_UINT32 mcd, PLI_BYTE8 *format, ...)",
          SAME_TYPE(&vpi_mcd_printf, PLI_INT32 (*)(PLI_UINT32 mcd, PLI_BYTE8 *format, ...)));
    CHECK("vpi_mcd_vprintf: PLI_INT32 (PLI_UINT32 mcd, PLI_BYTE8 *format, va_list ap)",
          SAME_TYPE(&vpi_mcd_vprintf, PLI_INT32 (*)(PLI_UINT32 mcd, PLI_BYTE8 *format, va_list
          ap)));
    CHECK("vpi_printf: PLI_INT32 (PLI_BYTE8 *format, ...)",
          SAME_TYPE(&vpi_printf, PLI_INT32 (*)(PLI_BYTE8 *format, ...)));
    CHECK("vpi_put_data: PLI_INT32 (PLI_INT32 id, PLI_BYTE8 *dataLoc, PLI_INT32 numOfBytes)",
          SAME_TYPE(&vpi_put_data, PLI_INT32 (*)(PLI_INT32 id, PLI_BYTE8 *dataLoc, PLI_INT32
          numOfBytes)));
    CHECK("vpi_put_delays: void (vpiHandle object, p_vpi_delay delay_p)",
          SAME_TYPE(&vpi_put_delays, void (*)(vpiHandle object, p_vpi_delay delay_p)));
    CHECK("vpi_put_userdata: PLI_INT32 (vpiHandle obj, void *userdata)",
          SAME_TYPE(&vpi_put_userdata, PLI_INT32 (*)(vpiHandle obj, void *userdata)));
    CHECK("vpi_put_value",
          SAME_TYPE(&vpi_put_value, vpiHandle (*)(vpiHandle object, p_vpi_value value_p,
          p_vpi_time time_p, PLI_INT32 flags)));
    CHECK("vpi_put_value_array",
          SAME_TYPE(&vpi_put_value_array, void (*)(vpiHandle object, p_vpi_arrayvalue
          arrayvalue_p, PLI_INT32 *index_p, PLI_UINT32 num)));
    CHECK("vpi_register_cb: vpiHandle (p_cb_data cb_data_p)",
          SAME_TYPE(&vpi_register_cb, vpiHandle (*)(p_cb_data cb_data_p)));
    CHECK("vpi_register_systf: vpiHandle (p_vpi_systf_data systf_data_p)",
          SAME_TYPE(&vpi_register_systf, vpiHandle (*)(p_vpi_systf_data systf_data_p)));
    CHECK("vpi_release_handle: PLI_INT32 (vpiHandle object)",
          SAME_TYPE(&vpi_release_handle, PLI_INT32 (*)(vpiHandle object)));
    CHECK("vpi_remove_cb: PLI_INT32 (vpiHandle cb_obj)",
          SAME_TYPE(&vpi_remove_cb, PLI_INT32 (*)(vpiHandle cb_obj)));
    CHECK("vpi_scan: vpiHandle (vpiHandle iterator)",
          SAME_TYPE(&vpi_scan, vpiHandle (*)(vpiHandle iterator)));
    CHECK("vpi_vprintf: PLI_INT32 (PLI_BYTE8 *format, va_list ap)",
          SAME_TYPE(&vpi_vprintf, PLI_INT32 (*)(PLI_BYTE8 *format, va_list ap)));
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = check_all;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
