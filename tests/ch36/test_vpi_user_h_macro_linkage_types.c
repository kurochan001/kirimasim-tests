/* VPI application of test_vpi_user_h_macro_linkage_types
   (IEEE 1800-2023 36.7, K.2). */
#include "vpi_user.h"

/* The sized types have to come from the header itself. */
typedef int8_t vt_int8;
typedef int32_t vt_int32;
typedef int64_t vt_int64;
typedef uint8_t vt_uint8;
typedef uint32_t vt_uint32;
typedef uint64_t vt_uint64;

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T.
   Nothing is called or linked: only the declarations of the header are used. */
#ifdef __cplusplus
template <typename A, typename B> struct vt_same { enum { value = 0 }; };
template <typename A> struct vt_same<A, A> { enum { value = 1 }; };
#define SAME_TYPE(e, T) ((int)vt_same<decltype(e), T>::value)
#else
#define SAME_TYPE(e, T) _Generic((e), T: 1, default: 0)
#endif

#include <string.h>

/* These macros only pass a macro name to strcmp, so they are expanded after
   the header, which is where the DLL qualifiers have to be. */
#define VT_STR_HELPER(x) #x
#define VT_STR(x) VT_STR_HELPER(x)

#if defined(_MSC_VER) || defined(__MINGW32__) || defined(__CYGWIN__)
#define VT_DLL_PLATFORM 1
#else
#define VT_DLL_PLATFORM 0
#endif
#ifdef PLI_DLLISPEC
#define VT_DLLISPEC_DEFINED 1
#else
#define VT_DLLISPEC_DEFINED 0
#endif
#ifdef PLI_DLLESPEC
#define VT_DLLESPEC_DEFINED 1
#else
#define VT_DLLESPEC_DEFINED 0
#endif
#ifdef VPI_USER_DEFINED_DLLISPEC
#define VT_DLLISPEC_FLAG 1
#else
#define VT_DLLISPEC_FLAG 0
#endif
#ifdef VPI_USER_DEFINED_DLLESPEC
#define VT_DLLESPEC_FLAG 1
#else
#define VT_DLLESPEC_FLAG 0
#endif

/* On MSVC, MinGW and Cygwin the header makes the qualifiers its own and
   removes them again; elsewhere it defines them empty and leaves them. */
#define VT_IMPORT_OK \
    (VT_DLL_PLATFORM ? (VT_DLLISPEC_DEFINED == 0) \
                     : (VT_DLLISPEC_DEFINED && strcmp(VT_STR(PLI_DLLISPEC), "") == 0))
#define VT_EXPORT_OK \
    (VT_DLL_PLATFORM ? (VT_DLLESPEC_DEFINED == 0) \
                     : (VT_DLLESPEC_DEFINED && strcmp(VT_STR(PLI_DLLESPEC), "") == 0))

#ifdef __cplusplus
extern "C" {
#endif

#define CHECK(what, ok) vpi_printf((PLI_BYTE8 *)"%s %d\n", what, (int)(ok))

static void register_all(void);

/* The application defines the array the header declares; its size is known
   from here on. */
void (*vlog_startup_routines[])(void) = {register_all, 0};

static PLI_INT32 check_all(p_cb_data data)
{
    PLI_INT32 reached;
    (void)data;

    /* The call itself is the check: this file is also compiled as C++. */
    reached = vpi_printf((PLI_BYTE8 *)"vpi_printf reached\n");
    CHECK("vpi routines called from this translation unit", reached > 0);

    CHECK("PLI types have the required widths",
          sizeof(PLI_INT32) == 4 && sizeof(PLI_UINT32) == 4 &&
          sizeof(PLI_INT16) == 2 && sizeof(PLI_UINT16) == 2 &&
          sizeof(PLI_BYTE8) == 1 && sizeof(PLI_UBYTE8) == 1 &&
          sizeof(PLI_INT64) == 8 && sizeof(PLI_UINT64) == 8);
    CHECK("PLI types have the required signedness",
          (PLI_INT32)-1 < 0 && (PLI_INT16)-1 < 0 && (PLI_INT64)-1 < 0 &&
          (PLI_UINT32)-1 > 0 && (PLI_UINT16)-1 > 0 && (PLI_UINT64)-1 > 0);
    CHECK("header makes int8_t int32_t int64_t uint8_t uint32_t uint64_t available",
          sizeof(vt_int8) == 1 && sizeof(vt_int32) == 4 && sizeof(vt_int64) == 8 &&
          sizeof(vt_uint8) == 1 && sizeof(vt_uint32) == 4 && sizeof(vt_uint64) == 8 &&
          (vt_int8)-1 < 0 && (vt_int32)-1 < 0 && (vt_int64)-1 < 0 &&
          (vt_uint8)-1 > 0 && (vt_uint32)-1 > 0 && (vt_uint64)-1 > 0);

    /* XXTERN adds the storage class and PROTO_PARAMS the parameter list. */
    CHECK("vpi_handle_multi has the three-parameter variadic prototype",
          SAME_TYPE(&vpi_handle_multi, vpiHandle (*)(PLI_INT32, vpiHandle, vpiHandle, ...)));
    CHECK("vpi_register_cb has the one-parameter prototype",
          SAME_TYPE(&vpi_register_cb, vpiHandle (*)(p_cb_data)));
    CHECK("vpi_get64 has the two-parameter prototype and PLI_INT64 result",
          SAME_TYPE(&vpi_get64, PLI_INT64 (*)(PLI_INT32, vpiHandle)));
    CHECK("vpi_printf has the variadic prototype",
          SAME_TYPE(&vpi_printf, PLI_INT32 (*)(PLI_BYTE8 *, ...)));
    CHECK("vpi_mcd_printf has the variadic prototype",
          SAME_TYPE(&vpi_mcd_printf, PLI_INT32 (*)(PLI_UINT32, PLI_BYTE8 *, ...)));

    CHECK("vpi_free_object retained with PLI_INT32 (vpiHandle)",
          SAME_TYPE(&vpi_free_object, PLI_INT32 (*)(vpiHandle)));
    CHECK("vpi_release_handle declared with PLI_INT32 (vpiHandle)",
          SAME_TYPE(&vpi_release_handle, PLI_INT32 (*)(vpiHandle)));

    CHECK("vlog_startup_routines is an array of void (void) pointers",
          sizeof(vlog_startup_routines) == 2 * sizeof(void (*)(void)) &&
          sizeof(vlog_startup_routines[0]) == sizeof(void (*)(void)) &&
          vlog_startup_routines[0] != 0);
    CHECK("vlog_startup_routines ends with a null pointer",
          sizeof(vlog_startup_routines) / sizeof(vlog_startup_routines[0]) == 2 &&
          vlog_startup_routines[1] == 0);

    CHECK("PLI_VEXTERN leaves the startup array for the application to define",
          sizeof(vlog_startup_routines) > sizeof(void (*)(void)));
    CHECK("PLI_EXTERN leaves the VPI routines with external linkage",
          &vpi_printf != 0 && &vpi_register_cb != 0 && &vpi_handle != 0);
    CHECK("PLI_DLLISPEC empty here and removed on MSVC MinGW Cygwin", VT_IMPORT_OK);
    CHECK("PLI_DLLESPEC empty here and removed on MSVC MinGW Cygwin", VT_EXPORT_OK);
    CHECK("a header-created DLL qualifier leaves no cleanup flag",
          !VT_DLLISPEC_FLAG && !VT_DLLESPEC_FLAG);
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

#ifdef __cplusplus
}
#endif
