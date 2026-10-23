/* VPI application of test_vpi_compatibility_h_1800v2012 (IEEE 1800-2023 36.12.2.1, L.2). */
/* The one compatibility macro, defined as 1 before any VPI header. */
#define VPI_COMPATIBILITY_VERSION_1800v2012 1
#include "vpi_user.h"

#ifdef VPI_COMPATIBILITY_H
#define COMPATIBILITY_INCLUDED 1
#else
#define COMPATIBILITY_INCLUDED 0
#endif

/* SHOW(f) prints the routine name and the name the macro f stands for. */
#define VT_STR(x) #x
#define VT_XSTR(x) VT_STR(x)
#define SHOW(f) vpi_printf((PLI_BYTE8 *)"%s %s\n", #f, VT_XSTR(f))

#ifdef __cplusplus
extern "C" {
#endif

/* Printed from the startup routine itself: vpi_register_cb is one of the
   remapped routines, so the application does not call it. */
static void show_all(void)
{
    vpi_printf((PLI_BYTE8 *)"VPI_COMPATIBILITY_H %d\n", COMPATIBILITY_INCLUDED);
    SHOW(vpi_compare_objects);
    SHOW(vpi_control);
    SHOW(vpi_get);
    SHOW(vpi_get_str);
    SHOW(vpi_get_value);
    SHOW(vpi_handle);
    SHOW(vpi_handle_by_index);
    SHOW(vpi_handle_by_multi_index);
    SHOW(vpi_handle_by_name);
    SHOW(vpi_handle_multi);
    SHOW(vpi_iterate);
    SHOW(vpi_put_value);
    SHOW(vpi_register_cb);
    SHOW(vpi_scan);
    /* vpi_user.h declares the routines after including vpi_compatibility.h,
       so the declarations are of the remapped names; sizeof does not call
       or link them. */
    vpi_printf((PLI_BYTE8 *)"remapped routines declared %d\n",
               (int)(sizeof(&vpi_compare_objects) > 0
                     && sizeof(&vpi_control) > 0
                     && sizeof(&vpi_get) > 0
                     && sizeof(&vpi_get_str) > 0
                     && sizeof(&vpi_get_value) > 0
                     && sizeof(&vpi_handle) > 0
                     && sizeof(&vpi_handle_by_index) > 0
                     && sizeof(&vpi_handle_by_multi_index) > 0
                     && sizeof(&vpi_handle_by_name) > 0
                     && sizeof(&vpi_handle_multi) > 0
                     && sizeof(&vpi_iterate) > 0
                     && sizeof(&vpi_put_value) > 0
                     && sizeof(&vpi_register_cb) > 0
                     && sizeof(&vpi_scan) > 0));
}

void (*vlog_startup_routines[])(void) = {show_all, 0};

#ifdef __cplusplus
}
#endif
