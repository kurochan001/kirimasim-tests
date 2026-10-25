/* VPI application of test_vpi_user_h_record_members
   (IEEE 1800-2023 36.7, K.2). */
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

/* The structure guards, looked at right after the header. */
#ifdef VPI_TIME
#define VPI_TIME_DEFINED 1
#else
#define VPI_TIME_DEFINED 0
#endif
#ifdef VPI_VECVAL
#define VPI_VECVAL_DEFINED 1
#else
#define VPI_VECVAL_DEFINED 0
#endif

#include <stddef.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

#define CHECK(what, ok) vpi_printf((PLI_BYTE8 *)"%s %d\n", what, (int)(ok))

/* Every member of the union lies at the offset of the union itself. */
#define AT_UNION_BASE(T, m) (offsetof(T, value.m) == offsetof(T, value))

static PLI_INT32 check_all(p_cb_data data)
{
    (void)data;

    /* t_vpi_time */
    CHECK("VPI_TIME defined", VPI_TIME_DEFINED);
    CHECK("t_vpi_time aliases s_vpi_time p_vpi_time",
          SAME_TYPE((s_vpi_time *)0, struct t_vpi_time *) &&
          SAME_TYPE((p_vpi_time)0, struct t_vpi_time *));
    CHECK("t_vpi_time field order type high low real",
          offsetof(s_vpi_time, type) < offsetof(s_vpi_time, high) &&
          offsetof(s_vpi_time, high) < offsetof(s_vpi_time, low) &&
          offsetof(s_vpi_time, low) < offsetof(s_vpi_time, real));
    CHECK("t_vpi_time.type PLI_INT32",
          SAME_TYPE(((s_vpi_time *)0)->type, PLI_INT32));
    CHECK("t_vpi_time.high PLI_UINT32",
          SAME_TYPE(((s_vpi_time *)0)->high, PLI_UINT32));
    CHECK("t_vpi_time.low PLI_UINT32",
          SAME_TYPE(((s_vpi_time *)0)->low, PLI_UINT32));
    CHECK("t_vpi_time.real double",
          SAME_TYPE(((s_vpi_time *)0)->real, double));

    /* t_vpi_delay */
    CHECK("t_vpi_delay aliases s_vpi_delay p_vpi_delay",
          SAME_TYPE((s_vpi_delay *)0, struct t_vpi_delay *) &&
          SAME_TYPE((p_vpi_delay)0, struct t_vpi_delay *));
    CHECK("t_vpi_delay field order da no_of_delays time_type mtm_flag append_flag pulsere_flag",
          offsetof(s_vpi_delay, da) < offsetof(s_vpi_delay, no_of_delays) &&
          offsetof(s_vpi_delay, no_of_delays) < offsetof(s_vpi_delay, time_type) &&
          offsetof(s_vpi_delay, time_type) < offsetof(s_vpi_delay, mtm_flag) &&
          offsetof(s_vpi_delay, mtm_flag) < offsetof(s_vpi_delay, append_flag) &&
          offsetof(s_vpi_delay, append_flag) < offsetof(s_vpi_delay, pulsere_flag));
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

    /* t_vpi_vecval */
    CHECK("VPI_VECVAL defined", VPI_VECVAL_DEFINED);
    CHECK("t_vpi_vecval aliases s_vpi_vecval p_vpi_vecval",
          SAME_TYPE((s_vpi_vecval *)0, struct t_vpi_vecval *) &&
          SAME_TYPE((p_vpi_vecval)0, struct t_vpi_vecval *));
    CHECK("t_vpi_vecval field order aval bval",
          offsetof(s_vpi_vecval, aval) < offsetof(s_vpi_vecval, bval));
    CHECK("t_vpi_vecval.aval PLI_UINT32",
          SAME_TYPE(((s_vpi_vecval *)0)->aval, PLI_UINT32));
    CHECK("t_vpi_vecval.bval PLI_UINT32",
          SAME_TYPE(((s_vpi_vecval *)0)->bval, PLI_UINT32));

    /* t_vpi_strengthval */
    CHECK("t_vpi_strengthval aliases s_vpi_strengthval p_vpi_strengthval",
          SAME_TYPE((s_vpi_strengthval *)0, struct t_vpi_strengthval *) &&
          SAME_TYPE((p_vpi_strengthval)0, struct t_vpi_strengthval *));
    CHECK("t_vpi_strengthval field order logic s0 s1",
          offsetof(s_vpi_strengthval, logic) < offsetof(s_vpi_strengthval, s0) &&
          offsetof(s_vpi_strengthval, s0) < offsetof(s_vpi_strengthval, s1));
    CHECK("t_vpi_strengthval.logic PLI_INT32",
          SAME_TYPE(((s_vpi_strengthval *)0)->logic, PLI_INT32));
    CHECK("t_vpi_strengthval.s0 PLI_INT32",
          SAME_TYPE(((s_vpi_strengthval *)0)->s0, PLI_INT32));
    CHECK("t_vpi_strengthval.s1 PLI_INT32",
          SAME_TYPE(((s_vpi_strengthval *)0)->s1, PLI_INT32));

    /* t_vpi_value */
    CHECK("t_vpi_value aliases s_vpi_value p_vpi_value",
          SAME_TYPE((s_vpi_value *)0, struct t_vpi_value *) &&
          SAME_TYPE((p_vpi_value)0, struct t_vpi_value *));
    CHECK("t_vpi_value field order format value",
          offsetof(s_vpi_value, format) < offsetof(s_vpi_value, value));
    CHECK("t_vpi_value.format PLI_INT32",
          SAME_TYPE(((s_vpi_value *)0)->format, PLI_INT32));
    CHECK("t_vpi_value.value is a union of its eight members",
          AT_UNION_BASE(s_vpi_value, str) && AT_UNION_BASE(s_vpi_value, scalar) &&
          AT_UNION_BASE(s_vpi_value, integer) && AT_UNION_BASE(s_vpi_value, real) &&
          AT_UNION_BASE(s_vpi_value, time) && AT_UNION_BASE(s_vpi_value, vector) &&
          AT_UNION_BASE(s_vpi_value, strength) && AT_UNION_BASE(s_vpi_value, misc));
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

    /* t_vpi_arrayvalue */
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
          AT_UNION_BASE(s_vpi_arrayvalue, integers) &&
          AT_UNION_BASE(s_vpi_arrayvalue, shortints) &&
          AT_UNION_BASE(s_vpi_arrayvalue, longints) &&
          AT_UNION_BASE(s_vpi_arrayvalue, rawvals) &&
          AT_UNION_BASE(s_vpi_arrayvalue, vectors) &&
          AT_UNION_BASE(s_vpi_arrayvalue, times) &&
          AT_UNION_BASE(s_vpi_arrayvalue, reals) &&
          AT_UNION_BASE(s_vpi_arrayvalue, shortreals));
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

    /* t_vpi_systf_data */
    CHECK("t_vpi_systf_data aliases s_vpi_systf_data p_vpi_systf_data",
          SAME_TYPE((s_vpi_systf_data *)0, struct t_vpi_systf_data *) &&
          SAME_TYPE((p_vpi_systf_data)0, struct t_vpi_systf_data *));
    CHECK("t_vpi_systf_data field order type sysfunctype tfname calltf compiletf sizetf user_data",
          offsetof(s_vpi_systf_data, type) < offsetof(s_vpi_systf_data, sysfunctype) &&
          offsetof(s_vpi_systf_data, sysfunctype) < offsetof(s_vpi_systf_data, tfname) &&
          offsetof(s_vpi_systf_data, tfname) < offsetof(s_vpi_systf_data, calltf) &&
          offsetof(s_vpi_systf_data, calltf) < offsetof(s_vpi_systf_data, compiletf) &&
          offsetof(s_vpi_systf_data, compiletf) < offsetof(s_vpi_systf_data, sizetf) &&
          offsetof(s_vpi_systf_data, sizetf) < offsetof(s_vpi_systf_data, user_data));
    CHECK("t_vpi_systf_data.type PLI_INT32",
          SAME_TYPE(((s_vpi_systf_data *)0)->type, PLI_INT32));
    CHECK("t_vpi_systf_data.sysfunctype PLI_INT32",
          SAME_TYPE(((s_vpi_systf_data *)0)->sysfunctype, PLI_INT32));
    CHECK("t_vpi_systf_data.tfname PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_systf_data *)0)->tfname, PLI_BYTE8 *));
    CHECK("t_vpi_systf_data.calltf PLI_INT32 (*)(PLI_BYTE8 *)",
          SAME_TYPE(((s_vpi_systf_data *)0)->calltf, PLI_INT32 (*)(PLI_BYTE8 *)));
    CHECK("t_vpi_systf_data.compiletf PLI_INT32 (*)(PLI_BYTE8 *)",
          SAME_TYPE(((s_vpi_systf_data *)0)->compiletf, PLI_INT32 (*)(PLI_BYTE8 *)));
    CHECK("t_vpi_systf_data.sizetf PLI_INT32 (*)(PLI_BYTE8 *)",
          SAME_TYPE(((s_vpi_systf_data *)0)->sizetf, PLI_INT32 (*)(PLI_BYTE8 *)));
    CHECK("t_vpi_systf_data.user_data PLI_BYTE8 *",
          SAME_TYPE(((s_vpi_systf_data *)0)->user_data, PLI_BYTE8 *));
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
