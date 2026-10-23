/* VPI application of test_sv_vpi_user_h_declarations (IEEE 1800-2023 36.7, M.2). */
#include "sv_vpi_user.h"

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T.
   Nothing is called or linked: only the declarations of the header are used. */
#ifdef __cplusplus
template <typename A, typename B> struct vt_same { enum { value = 0 }; };
template <typename A> struct vt_same<A, A> { enum { value = 1 }; };
#define SAME_TYPE(e, T) ((int)vt_same<decltype(e), T>::value)
#else
#define SAME_TYPE(e, T) _Generic((e), T: 1, default: 0)
#endif

/* What the preprocessor sees right after the header, before anything else. */
#ifdef VPI_USER_H
#define BASE_OK 1
#else
#define BASE_OK 0
#endif
/* A second inclusion has to add nothing: its typedefs and structure
   definitions would otherwise be defined twice, which C++ rejects. */
#ifdef SV_VPI_USER_H
#include "sv_vpi_user.h"
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
    CHECK("SV_VPI_USER_H defined and a second include adds nothing",
          GUARD_OK);
    CHECK("VPI_USER_H defined by including sv_vpi_user.h alone",
          BASE_OK);
    CHECK("t_vpi_assertion_step_info aliases s_ and p_vpi_assertion_step_info",
          SAME_TYPE((s_vpi_assertion_step_info *)0, struct t_vpi_assertion_step_info *) &&
          SAME_TYPE((p_vpi_assertion_step_info)0, struct t_vpi_assertion_step_info *));
    CHECK("t_vpi_assertion_step_info order matched_expression_count matched_exprs stateFrom stateTo",
          offsetof(s_vpi_assertion_step_info, matched_expression_count) <
          offsetof(s_vpi_assertion_step_info, matched_exprs) &&
          offsetof(s_vpi_assertion_step_info, matched_exprs) < offsetof(s_vpi_assertion_step_info,
          stateFrom) && offsetof(s_vpi_assertion_step_info, stateFrom) <
          offsetof(s_vpi_assertion_step_info, stateTo));
    CHECK("t_vpi_assertion_step_info.matched_expression_count PLI_INT32",
          SAME_TYPE(((s_vpi_assertion_step_info *)0)->matched_expression_count, PLI_INT32));
    CHECK("t_vpi_assertion_step_info.matched_exprs vpiHandle *",
          SAME_TYPE(((s_vpi_assertion_step_info *)0)->matched_exprs, vpiHandle *));
    CHECK("t_vpi_assertion_step_info.stateFrom PLI_INT32",
          SAME_TYPE(((s_vpi_assertion_step_info *)0)->stateFrom, PLI_INT32));
    CHECK("t_vpi_assertion_step_info.stateTo PLI_INT32",
          SAME_TYPE(((s_vpi_assertion_step_info *)0)->stateTo, PLI_INT32));
    CHECK("t_vpi_attempt_info aliases s_vpi_attempt_info p_vpi_attempt_info",
          SAME_TYPE((s_vpi_attempt_info *)0, struct t_vpi_attempt_info *) &&
          SAME_TYPE((p_vpi_attempt_info)0, struct t_vpi_attempt_info *));
    CHECK("t_vpi_attempt_info field order detail attemptStartTime",
          offsetof(s_vpi_attempt_info, detail) < offsetof(s_vpi_attempt_info, attemptStartTime));
    CHECK("t_vpi_attempt_info.detail.failExpr vpiHandle",
          SAME_TYPE(((s_vpi_attempt_info *)0)->detail.failExpr, vpiHandle));
    CHECK("t_vpi_attempt_info.detail.step p_vpi_assertion_step_info",
          SAME_TYPE(((s_vpi_attempt_info *)0)->detail.step, p_vpi_assertion_step_info));
    CHECK("t_vpi_attempt_info.detail is a union of failExpr and step",
          offsetof(s_vpi_attempt_info, detail.failExpr) == offsetof(s_vpi_attempt_info,
          detail.step));
    CHECK("t_vpi_attempt_info.attemptStartTime s_vpi_time",
          SAME_TYPE(((s_vpi_attempt_info *)0)->attemptStartTime, s_vpi_time));
    CHECK("vpi_assertion_callback_func: PLI_INT32 (reason, cb_time, assertion, info, user_data)",
          SAME_TYPE((vpi_assertion_callback_func *)0, PLI_INT32 (*)(PLI_INT32 reason, p_vpi_time
          cb_time, vpiHandle assertion, p_vpi_attempt_info info, PLI_BYTE8 *user_data)));
    CHECK("vpi_register_assertion_cb: vpiHandle (assertion, reason, cb_rtn, user_data)",
          SAME_TYPE(&vpi_register_assertion_cb, vpiHandle (*)(vpiHandle assertion, PLI_INT32
          reason, vpi_assertion_callback_func *cb_rtn, PLI_BYTE8 *user_data)));
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
