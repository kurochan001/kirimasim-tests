/* VPI application of test_vpi_value_time_delay_structures (IEEE 1800-2023 38.10, 38.15). */
#include <stddef.h>
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

#define CHECK(what, ok) vpi_printf((PLI_BYTE8 *)"%s %d\n", what, (int)(ok))
/* No parentheses around the member access: decltype gives its declared type. */
#define F(S, f) ((S *)0)->f
#define AT(S, f) offsetof(S, f)

typedef struct t_vpi_time *time_ptr;
typedef struct t_vpi_vecval *vecval_ptr;
typedef struct t_vpi_strengthval *strength_ptr;

static PLI_INT32 check_all(p_cb_data data)
{
    (void)data;
    CHECK("s_vpi_time and p_vpi_time name struct t_vpi_time",
          SAME_TYPE((s_vpi_time *)0, struct t_vpi_time *) && SAME_TYPE((p_vpi_time)0, time_ptr));
    CHECK("s_vpi_time type PLI_INT32", SAME_TYPE(F(s_vpi_time, type), PLI_INT32));
    CHECK("s_vpi_time high PLI_UINT32", SAME_TYPE(F(s_vpi_time, high), PLI_UINT32));
    CHECK("s_vpi_time low PLI_UINT32", SAME_TYPE(F(s_vpi_time, low), PLI_UINT32));
    CHECK("s_vpi_time real double", SAME_TYPE(F(s_vpi_time, real), double));
    CHECK("s_vpi_time order type high low real",
          AT(s_vpi_time, type) < AT(s_vpi_time, high) && AT(s_vpi_time, high) <
          AT(s_vpi_time, low) && AT(s_vpi_time, low) < AT(s_vpi_time, real));
    vpi_printf((PLI_BYTE8 *)"time types vpiScaledRealTime %d vpiSimTime %d vpiSuppressTime %d\n",
               (int)vpiScaledRealTime, (int)vpiSimTime, (int)vpiSuppressTime);

    CHECK("s_vpi_delay and p_vpi_delay name struct t_vpi_delay",
          SAME_TYPE((s_vpi_delay *)0, struct t_vpi_delay *) &&
          SAME_TYPE((p_vpi_delay)0, struct t_vpi_delay *));
    CHECK("s_vpi_delay da struct t_vpi_time *", SAME_TYPE(F(s_vpi_delay, da), time_ptr));
    CHECK("s_vpi_delay no_of_delays time_type mtm_flag append_flag pulsere_flag PLI_INT32",
          SAME_TYPE(F(s_vpi_delay, no_of_delays), PLI_INT32) &&
          SAME_TYPE(F(s_vpi_delay, time_type), PLI_INT32) &&
          SAME_TYPE(F(s_vpi_delay, mtm_flag), PLI_INT32) &&
          SAME_TYPE(F(s_vpi_delay, append_flag), PLI_INT32) &&
          SAME_TYPE(F(s_vpi_delay, pulsere_flag), PLI_INT32));
    CHECK("s_vpi_delay order da no_of_delays time_type mtm_flag append_flag pulsere_flag",
          AT(s_vpi_delay, da) < AT(s_vpi_delay, no_of_delays) &&
          AT(s_vpi_delay, no_of_delays) < AT(s_vpi_delay, time_type) &&
          AT(s_vpi_delay, time_type) < AT(s_vpi_delay, mtm_flag) &&
          AT(s_vpi_delay, mtm_flag) < AT(s_vpi_delay, append_flag) &&
          AT(s_vpi_delay, append_flag) < AT(s_vpi_delay, pulsere_flag));

    CHECK("s_vpi_value and p_vpi_value name struct t_vpi_value",
          SAME_TYPE((s_vpi_value *)0, struct t_vpi_value *) &&
          SAME_TYPE((p_vpi_value)0, struct t_vpi_value *));
    CHECK("s_vpi_value format PLI_INT32", SAME_TYPE(F(s_vpi_value, format), PLI_INT32));
    CHECK("s_vpi_value value.str PLI_BYTE8 *", SAME_TYPE(F(s_vpi_value, value.str), PLI_BYTE8 *));
    CHECK("s_vpi_value value.scalar PLI_INT32", SAME_TYPE(F(s_vpi_value, value.scalar), PLI_INT32));
    CHECK("s_vpi_value value.integer PLI_INT32",
          SAME_TYPE(F(s_vpi_value, value.integer), PLI_INT32));
    CHECK("s_vpi_value value.real double", SAME_TYPE(F(s_vpi_value, value.real), double));
    CHECK("s_vpi_value value.time struct t_vpi_time *",
          SAME_TYPE(F(s_vpi_value, value.time), time_ptr));
    CHECK("s_vpi_value value.vector struct t_vpi_vecval *",
          SAME_TYPE(F(s_vpi_value, value.vector), vecval_ptr));
    CHECK("s_vpi_value value.strength struct t_vpi_strengthval *",
          SAME_TYPE(F(s_vpi_value, value.strength), strength_ptr));
    CHECK("s_vpi_value value.misc PLI_BYTE8 *", SAME_TYPE(F(s_vpi_value, value.misc), PLI_BYTE8 *));
    CHECK("s_vpi_value format before value, value a union",
          AT(s_vpi_value, format) < AT(s_vpi_value, value) &&
          AT(s_vpi_value, value.str) == AT(s_vpi_value, value.scalar) &&
          AT(s_vpi_value, value.str) == AT(s_vpi_value, value.integer) &&
          AT(s_vpi_value, value.str) == AT(s_vpi_value, value.real) &&
          AT(s_vpi_value, value.str) == AT(s_vpi_value, value.time) &&
          AT(s_vpi_value, value.str) == AT(s_vpi_value, value.vector) &&
          AT(s_vpi_value, value.str) == AT(s_vpi_value, value.strength) &&
          AT(s_vpi_value, value.str) == AT(s_vpi_value, value.misc));

    CHECK("s_vpi_vecval and p_vpi_vecval name struct t_vpi_vecval",
          SAME_TYPE((s_vpi_vecval *)0, vecval_ptr) && SAME_TYPE((p_vpi_vecval)0, vecval_ptr));
    CHECK("s_vpi_vecval aval PLI_UINT32", SAME_TYPE(F(s_vpi_vecval, aval), PLI_UINT32));
    CHECK("s_vpi_vecval bval PLI_UINT32", SAME_TYPE(F(s_vpi_vecval, bval), PLI_UINT32));
    CHECK("s_vpi_vecval order aval bval", AT(s_vpi_vecval, aval) < AT(s_vpi_vecval, bval));

    CHECK("s_vpi_strengthval and p_vpi_strengthval name struct t_vpi_strengthval",
          SAME_TYPE((s_vpi_strengthval *)0, strength_ptr) &&
          SAME_TYPE((p_vpi_strengthval)0, strength_ptr));
    CHECK("s_vpi_strengthval logic s0 s1 PLI_INT32",
          SAME_TYPE(F(s_vpi_strengthval, logic), PLI_INT32) &&
          SAME_TYPE(F(s_vpi_strengthval, s0), PLI_INT32) &&
          SAME_TYPE(F(s_vpi_strengthval, s1), PLI_INT32));
    CHECK("s_vpi_strengthval order logic s0 s1",
          AT(s_vpi_strengthval, logic) < AT(s_vpi_strengthval, s0) &&
          AT(s_vpi_strengthval, s0) < AT(s_vpi_strengthval, s1));
    vpi_printf((PLI_BYTE8 *)"logic values vpi0 %d vpi1 %d vpiZ %d vpiX %d\n", (int)vpi0,
               (int)vpi1, (int)vpiZ, (int)vpiX);
    vpi_printf((PLI_BYTE8 *)"strengths vpiSupplyDrive %02x vpiStrongDrive %02x vpiPullDrive %02x "
               "vpiWeakDrive %02x vpiLargeCharge %02x vpiMediumCharge %02x vpiSmallCharge %02x "
               "vpiHiZ %02x\n", (unsigned)vpiSupplyDrive, (unsigned)vpiStrongDrive,
               (unsigned)vpiPullDrive, (unsigned)vpiWeakDrive, (unsigned)vpiLargeCharge,
               (unsigned)vpiMediumCharge, (unsigned)vpiSmallCharge, (unsigned)vpiHiZ);

    CHECK("vpi_get_time void (*)(vpiHandle, p_vpi_time)",
          SAME_TYPE(&vpi_get_time, void (*)(vpiHandle, p_vpi_time)));
    CHECK("vpi_get_delays void (*)(vpiHandle, p_vpi_delay)",
          SAME_TYPE(&vpi_get_delays, void (*)(vpiHandle, p_vpi_delay)));
    CHECK("vpi_put_delays void (*)(vpiHandle, p_vpi_delay)",
          SAME_TYPE(&vpi_put_delays, void (*)(vpiHandle, p_vpi_delay)));
    CHECK("vpi_get_value void (*)(vpiHandle, p_vpi_value)",
          SAME_TYPE(&vpi_get_value, void (*)(vpiHandle, p_vpi_value)));
    CHECK("vpi_put_value vpiHandle (*)(vpiHandle, p_vpi_value, p_vpi_time, PLI_INT32)",
          SAME_TYPE(&vpi_put_value, vpiHandle (*)(vpiHandle, p_vpi_value, p_vpi_time, PLI_INT32)));
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
