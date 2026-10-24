/* VPI application of test_vpi_assertion_attempt_info_structures (IEEE 1800-2023 39.4.2). */
#include <stddef.h>
#include <string.h>
#include "sv_vpi_user.h"

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

static PLI_INT32 check_all(p_cb_data data)
{
    (void)data;
    CHECK("t_vpi_assertion_step_info aliases s_vpi_assertion_step_info p_vpi_assertion_step_info",
          SAME_TYPE((s_vpi_assertion_step_info *)0, struct t_vpi_assertion_step_info *) &&
          SAME_TYPE((p_vpi_assertion_step_info)0, struct t_vpi_assertion_step_info *));
    CHECK("matched_expression_count PLI_INT32",
          SAME_TYPE(((s_vpi_assertion_step_info *)0)->matched_expression_count, PLI_INT32));
    CHECK("matched_exprs vpiHandle *",
          SAME_TYPE(((s_vpi_assertion_step_info *)0)->matched_exprs, vpiHandle *));
    CHECK("stateFrom and stateTo PLI_INT32",
          SAME_TYPE(((s_vpi_assertion_step_info *)0)->stateFrom, PLI_INT32) &&
          SAME_TYPE(((s_vpi_assertion_step_info *)0)->stateTo, PLI_INT32));
    CHECK("step field order matched_expression_count matched_exprs stateFrom stateTo",
          offsetof(s_vpi_assertion_step_info, matched_expression_count) <
          offsetof(s_vpi_assertion_step_info, matched_exprs) &&
          offsetof(s_vpi_assertion_step_info, matched_exprs) <
          offsetof(s_vpi_assertion_step_info, stateFrom) &&
          offsetof(s_vpi_assertion_step_info, stateFrom) <
          offsetof(s_vpi_assertion_step_info, stateTo));
    CHECK("t_vpi_attempt_info aliases s_vpi_attempt_info p_vpi_attempt_info",
          SAME_TYPE((s_vpi_attempt_info *)0, struct t_vpi_attempt_info *) &&
          SAME_TYPE((p_vpi_attempt_info)0, struct t_vpi_attempt_info *));
    CHECK("detail.failExpr vpiHandle",
          SAME_TYPE(((s_vpi_attempt_info *)0)->detail.failExpr, vpiHandle));
    CHECK("detail.step p_vpi_assertion_step_info",
          SAME_TYPE(((s_vpi_attempt_info *)0)->detail.step, p_vpi_assertion_step_info));
    CHECK("failExpr and step share the detail union",
          offsetof(s_vpi_attempt_info, detail.failExpr) ==
          offsetof(s_vpi_attempt_info, detail.step));
    CHECK("attemptStartTime s_vpi_time",
          SAME_TYPE(((s_vpi_attempt_info *)0)->attemptStartTime, s_vpi_time));
    CHECK("attempt field order detail attemptStartTime",
          offsetof(s_vpi_attempt_info, detail) < offsetof(s_vpi_attempt_info, attemptStartTime));
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = check_all;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
