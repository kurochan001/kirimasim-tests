/* VPI application of test_vpi_user_h_type_declarations (IEEE 1800-2023 36.7, K.2). */
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

/* The sized types have to come from the header itself. */
typedef int8_t vt_int8;
typedef int32_t vt_int32;
typedef int64_t vt_int64;
typedef uint8_t vt_uint8;
typedef uint32_t vt_uint32;
typedef uint64_t vt_uint64;
/* What the preprocessor sees right after the header, before anything else. */
#ifdef PLI_TYPES
#define PLI_TYPES_DEFINED 1
#else
#define PLI_TYPES_DEFINED 0
#endif
#ifdef SVPI_TYPES
#define SVPI_TYPES_DEFINED 1
#else
#define SVPI_TYPES_DEFINED 0
#endif
#if defined(va_start) && defined(va_arg) && defined(va_end)
#define STDARG_OK 1
#else
#define STDARG_OK 0
#endif
/* A second inclusion has to add nothing: its typedefs and structure
   definitions would otherwise be defined twice, which C++ rejects. */
#ifdef VPI_USER_H
#include "vpi_user.h"
#define GUARD_OK 1
#else
#define GUARD_OK 0
#endif
#include <stddef.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

#define CHECK(what, ok) vpi_printf((PLI_BYTE8 *)"%s %d\n", what, (int)(ok))

static PLI_INT32 check_all(p_cb_data data)
{
    (void)data;
    CHECK("PLI_TYPES defined",
          PLI_TYPES_DEFINED);
    CHECK("PLI_INT32 is int",
          SAME_TYPE((PLI_INT32)0, int));
    CHECK("PLI_UINT32 is unsigned int",
          SAME_TYPE((PLI_UINT32)0, unsigned int));
    CHECK("PLI_INT16 is short",
          SAME_TYPE((PLI_INT16)0, short));
    CHECK("PLI_UINT16 is unsigned short",
          SAME_TYPE((PLI_UINT16)0, unsigned short));
    CHECK("PLI_BYTE8 is char",
          SAME_TYPE((PLI_BYTE8)0, char));
    CHECK("PLI_UBYTE8 is unsigned char",
          SAME_TYPE((PLI_UBYTE8)0, unsigned char));
    CHECK("SVPI_TYPES defined",
          SVPI_TYPES_DEFINED);
    CHECK("PLI_INT64 is int64_t",
          SAME_TYPE((PLI_INT64)0, int64_t));
    CHECK("PLI_UINT64 is uint64_t",
          SAME_TYPE((PLI_UINT64)0, uint64_t));
    CHECK("int8_t int32_t int64_t uint8_t uint32_t uint64_t sizes 1 4 8",
          sizeof(vt_int8) == 1 && sizeof(vt_int32) == 4 && sizeof(vt_int64) == 8 &&
          sizeof(vt_uint8) == 1 && sizeof(vt_uint32) == 4 && sizeof(vt_uint64) == 8);
    CHECK("int8_t int32_t int64_t signed and uint8_t uint32_t uint64_t unsigned",
          (vt_int8)-1 < 0 && (vt_int32)-1 < 0 && (vt_int64)-1 < 0 && (vt_uint8)-1 > 0 &&
          (vt_uint32)-1 > 0 && (vt_uint64)-1 > 0);
    CHECK("vpiHandle is PLI_UINT32 *",
          SAME_TYPE((vpiHandle)0, PLI_UINT32 *));
    CHECK("VPI_USER_H defined and a second include adds nothing",
          GUARD_OK);
    CHECK("stdarg.h included (va_start, va_arg, va_end)",
          STDARG_OK);
    CHECK("t_vpi_delay aliases s_vpi_delay p_vpi_delay",
          SAME_TYPE((s_vpi_delay *)0, struct t_vpi_delay *) && SAME_TYPE((p_vpi_delay)0, struct
          t_vpi_delay *));
    CHECK("t_vpi_delay field order da no_of_delays time_type mtm_flag append_flag pulsere_flag",
          offsetof(s_vpi_delay, da) < offsetof(s_vpi_delay, no_of_delays) && offsetof(s_vpi_delay,
          no_of_delays) < offsetof(s_vpi_delay, time_type) && offsetof(s_vpi_delay, time_type) <
          offsetof(s_vpi_delay, mtm_flag) && offsetof(s_vpi_delay, mtm_flag) <
          offsetof(s_vpi_delay, append_flag) && offsetof(s_vpi_delay, append_flag) <
          offsetof(s_vpi_delay, pulsere_flag));
    CHECK("t_vpi_delay.da struct t_vpi_time *",
          SAME_TYPE(((s_vpi_delay *)0)->da, struct t_vpi_time *));
    CHECK("t_vpi_delay.no_of_delays PLI_INT32",
          SAME_TYPE(((s_vpi_delay *)0)->no_of_delays, PLI_INT32));
    CHECK("t_vpi_delay.time_type PLI_INT32",
          SAME_TYPE(((s_vpi_delay *)0)->time_type, PLI_INT32));
    CHECK("t_vpi_delay.mtm_flag PLI_INT32",
          SAME_TYPE(((s_vpi_delay *)0)->mtm_flag, PLI_INT32));
    CHECK("t_vpi_delay.append_flag PLI_INT32",
          SAME_TYPE(((s_vpi_delay *)0)->append_flag, PLI_INT32));
    CHECK("t_vpi_delay.pulsere_flag PLI_INT32",
          SAME_TYPE(((s_vpi_delay *)0)->pulsere_flag, PLI_INT32));
    CHECK("t_vpi_value aliases s_vpi_value p_vpi_value",
          SAME_TYPE((s_vpi_value *)0, struct t_vpi_value *) && SAME_TYPE((p_vpi_value)0, struct
          t_vpi_value *));
    CHECK("t_vpi_value field order format value",
          offsetof(s_vpi_value, format) < offsetof(s_vpi_value, value));
    CHECK("t_vpi_value.format PLI_INT32",
          SAME_TYPE(((s_vpi_value *)0)->format, PLI_INT32));
    CHECK("t_vpi_value.value is a union of its eight members",
          offsetof(s_vpi_value, value.str) == offsetof(s_vpi_value, value.scalar) &&
          offsetof(s_vpi_value, value.str) == offsetof(s_vpi_value, value.integer) &&
          offsetof(s_vpi_value, value.str) == offsetof(s_vpi_value, value.real) &&
          offsetof(s_vpi_value, value.str) == offsetof(s_vpi_value, value.time) &&
          offsetof(s_vpi_value, value.str) == offsetof(s_vpi_value, value.vector) &&
          offsetof(s_vpi_value, value.str) == offsetof(s_vpi_value, value.strength) &&
          offsetof(s_vpi_value, value.str) == offsetof(s_vpi_value, value.misc));
    CHECK("t_vpi_value.value.str PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_value *)0)->value.str, PLI_BYTE8 *));
    CHECK("t_vpi_value.value.scalar PLI_INT32",
          SAME_TYPE(((s_vpi_value *)0)->value.scalar, PLI_INT32));
    CHECK("t_vpi_value.value.integer PLI_INT32",
          SAME_TYPE(((s_vpi_value *)0)->value.integer, PLI_INT32));
    CHECK("t_vpi_value.value.real double",
          SAME_TYPE(((s_vpi_value *)0)->value.real, double));
    CHECK("t_vpi_value.value.time struct t_vpi_time *",
          SAME_TYPE(((s_vpi_value *)0)->value.time, struct t_vpi_time *));
    CHECK("t_vpi_value.value.vector struct t_vpi_vecval *",
          SAME_TYPE(((s_vpi_value *)0)->value.vector, struct t_vpi_vecval *));
    CHECK("t_vpi_value.value.strength struct t_vpi_strengthval *",
          SAME_TYPE(((s_vpi_value *)0)->value.strength, struct t_vpi_strengthval *));
    CHECK("t_vpi_value.value.misc PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_value *)0)->value.misc, PLI_BYTE8 *));
    CHECK("t_vpi_arrayvalue aliases s_vpi_arrayvalue p_vpi_arrayvalue",
          SAME_TYPE((s_vpi_arrayvalue *)0, struct t_vpi_arrayvalue *) &&
          SAME_TYPE((p_vpi_arrayvalue)0, struct t_vpi_arrayvalue *));
    CHECK("t_vpi_arrayvalue field order format flags value",
          offsetof(s_vpi_arrayvalue, format) < offsetof(s_vpi_arrayvalue, flags) &&
          offsetof(s_vpi_arrayvalue, flags) < offsetof(s_vpi_arrayvalue, value));
    CHECK("t_vpi_arrayvalue.format PLI_UINT32",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->format, PLI_UINT32));
    CHECK("t_vpi_arrayvalue.flags PLI_UINT32",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->flags, PLI_UINT32));
    CHECK("t_vpi_arrayvalue.value is a union of its eight members",
          offsetof(s_vpi_arrayvalue, value.integers) == offsetof(s_vpi_arrayvalue,
          value.shortints) && offsetof(s_vpi_arrayvalue, value.integers) ==
          offsetof(s_vpi_arrayvalue, value.longints) && offsetof(s_vpi_arrayvalue, value.integers)
          == offsetof(s_vpi_arrayvalue, value.rawvals) && offsetof(s_vpi_arrayvalue,
          value.integers) == offsetof(s_vpi_arrayvalue, value.vectors) &&
          offsetof(s_vpi_arrayvalue, value.integers) == offsetof(s_vpi_arrayvalue, value.times) &&
          offsetof(s_vpi_arrayvalue, value.integers) == offsetof(s_vpi_arrayvalue, value.reals) &&
          offsetof(s_vpi_arrayvalue, value.integers) == offsetof(s_vpi_arrayvalue,
          value.shortreals));
    CHECK("t_vpi_arrayvalue.value.integers PLI_INT32 *",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->value.integers, PLI_INT32 *));
    CHECK("t_vpi_arrayvalue.value.shortints PLI_INT16 *",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->value.shortints, PLI_INT16 *));
    CHECK("t_vpi_arrayvalue.value.longints PLI_INT64 *",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->value.longints, PLI_INT64 *));
    CHECK("t_vpi_arrayvalue.value.rawvals PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->value.rawvals, PLI_BYTE8 *));
    CHECK("t_vpi_arrayvalue.value.vectors struct t_vpi_vecval *",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->value.vectors, struct t_vpi_vecval *));
    CHECK("t_vpi_arrayvalue.value.times struct t_vpi_time *",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->value.times, struct t_vpi_time *));
    CHECK("t_vpi_arrayvalue.value.reals double *",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->value.reals, double *));
    CHECK("t_vpi_arrayvalue.value.shortreals float *",
          SAME_TYPE(((s_vpi_arrayvalue *)0)->value.shortreals, float *));
    CHECK("t_vpi_vlog_info aliases s_vpi_vlog_info p_vpi_vlog_info",
          SAME_TYPE((s_vpi_vlog_info *)0, struct t_vpi_vlog_info *) &&
          SAME_TYPE((p_vpi_vlog_info)0, struct t_vpi_vlog_info *));
    CHECK("t_vpi_vlog_info field order argc argv product version",
          offsetof(s_vpi_vlog_info, argc) < offsetof(s_vpi_vlog_info, argv) &&
          offsetof(s_vpi_vlog_info, argv) < offsetof(s_vpi_vlog_info, product) &&
          offsetof(s_vpi_vlog_info, product) < offsetof(s_vpi_vlog_info, version));
    CHECK("t_vpi_vlog_info.argc PLI_INT32",
          SAME_TYPE(((s_vpi_vlog_info *)0)->argc, PLI_INT32));
    CHECK("t_vpi_vlog_info.argv PLI_BYTE8 **",
          SAME_TYPE(((s_vpi_vlog_info *)0)->argv, PLI_BYTE8 **));
    CHECK("t_vpi_vlog_info.product PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_vlog_info *)0)->product, PLI_BYTE8 *));
    CHECK("t_vpi_vlog_info.version PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_vlog_info *)0)->version, PLI_BYTE8 *));
    CHECK("t_vpi_error_info aliases s_vpi_error_info p_vpi_error_info",
          SAME_TYPE((s_vpi_error_info *)0, struct t_vpi_error_info *) &&
          SAME_TYPE((p_vpi_error_info)0, struct t_vpi_error_info *));
    CHECK("t_vpi_error_info field order state level message product code file line",
          offsetof(s_vpi_error_info, state) < offsetof(s_vpi_error_info, level) &&
          offsetof(s_vpi_error_info, level) < offsetof(s_vpi_error_info, message) &&
          offsetof(s_vpi_error_info, message) < offsetof(s_vpi_error_info, product) &&
          offsetof(s_vpi_error_info, product) < offsetof(s_vpi_error_info, code) &&
          offsetof(s_vpi_error_info, code) < offsetof(s_vpi_error_info, file) &&
          offsetof(s_vpi_error_info, file) < offsetof(s_vpi_error_info, line));
    CHECK("t_vpi_error_info.state PLI_INT32",
          SAME_TYPE(((s_vpi_error_info *)0)->state, PLI_INT32));
    CHECK("t_vpi_error_info.level PLI_INT32",
          SAME_TYPE(((s_vpi_error_info *)0)->level, PLI_INT32));
    CHECK("t_vpi_error_info.message PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_error_info *)0)->message, PLI_BYTE8 *));
    CHECK("t_vpi_error_info.product PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_error_info *)0)->product, PLI_BYTE8 *));
    CHECK("t_vpi_error_info.code PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_error_info *)0)->code, PLI_BYTE8 *));
    CHECK("t_vpi_error_info.file PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_error_info *)0)->file, PLI_BYTE8 *));
    CHECK("t_vpi_error_info.line PLI_INT32",
          SAME_TYPE(((s_vpi_error_info *)0)->line, PLI_INT32));
    CHECK("t_cb_data aliases s_cb_data p_cb_data",
          SAME_TYPE((s_cb_data *)0, struct t_cb_data *) && SAME_TYPE((p_cb_data)0, struct
          t_cb_data *));
    CHECK("t_cb_data field order reason cb_rtn obj time value index user_data",
          offsetof(s_cb_data, reason) < offsetof(s_cb_data, cb_rtn) && offsetof(s_cb_data, cb_rtn)
          < offsetof(s_cb_data, obj) && offsetof(s_cb_data, obj) < offsetof(s_cb_data, time) &&
          offsetof(s_cb_data, time) < offsetof(s_cb_data, value) && offsetof(s_cb_data, value) <
          offsetof(s_cb_data, index) && offsetof(s_cb_data, index) < offsetof(s_cb_data,
          user_data));
    CHECK("t_cb_data.reason PLI_INT32",
          SAME_TYPE(((s_cb_data *)0)->reason, PLI_INT32));
    CHECK("t_cb_data.cb_rtn PLI_INT32 (*)(struct t_cb_data *)",
          SAME_TYPE(((s_cb_data *)0)->cb_rtn, PLI_INT32 (*)(struct t_cb_data *)));
    CHECK("t_cb_data.obj vpiHandle",
          SAME_TYPE(((s_cb_data *)0)->obj, vpiHandle));
    CHECK("t_cb_data.time p_vpi_time",
          SAME_TYPE(((s_cb_data *)0)->time, p_vpi_time));
    CHECK("t_cb_data.value p_vpi_value",
          SAME_TYPE(((s_cb_data *)0)->value, p_vpi_value));
    CHECK("t_cb_data.index PLI_INT32",
          SAME_TYPE(((s_cb_data *)0)->index, PLI_INT32));
    CHECK("t_cb_data.user_data PLI_BYTE8 *",
          SAME_TYPE(((s_cb_data *)0)->user_data, PLI_BYTE8 *));
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
