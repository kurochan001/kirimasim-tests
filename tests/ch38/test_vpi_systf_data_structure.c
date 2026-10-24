/* VPI application of test_vpi_systf_data_structure (IEEE 1800-2023 38.37). */
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

typedef PLI_INT32 (*routine_t)(PLI_BYTE8 *);

#define CHECK(what, ok) vpi_printf((PLI_BYTE8 *)"%s %d\n", what, (int)(ok))

static PLI_INT32 check_all(p_cb_data data)
{
    (void)data;
    CHECK("t_vpi_systf_data aliases s_vpi_systf_data p_vpi_systf_data",
          SAME_TYPE((s_vpi_systf_data *)0, struct t_vpi_systf_data *) &&
          SAME_TYPE((p_vpi_systf_data)0, struct t_vpi_systf_data *));
    CHECK("type PLI_INT32", SAME_TYPE(((s_vpi_systf_data *)0)->type, PLI_INT32));
    CHECK("sysfunctype PLI_INT32", SAME_TYPE(((s_vpi_systf_data *)0)->sysfunctype, PLI_INT32));
    CHECK("tfname PLI_BYTE8 *", SAME_TYPE(((s_vpi_systf_data *)0)->tfname, PLI_BYTE8 *));
    CHECK("calltf PLI_INT32 (*)(PLI_BYTE8 *)",
          SAME_TYPE(((s_vpi_systf_data *)0)->calltf, routine_t));
    CHECK("compiletf PLI_INT32 (*)(PLI_BYTE8 *)",
          SAME_TYPE(((s_vpi_systf_data *)0)->compiletf, routine_t));
    CHECK("sizetf PLI_INT32 (*)(PLI_BYTE8 *)",
          SAME_TYPE(((s_vpi_systf_data *)0)->sizetf, routine_t));
    CHECK("user_data PLI_BYTE8 *", SAME_TYPE(((s_vpi_systf_data *)0)->user_data, PLI_BYTE8 *));
    CHECK("field order type sysfunctype tfname calltf compiletf sizetf user_data",
          offsetof(s_vpi_systf_data, type) < offsetof(s_vpi_systf_data, sysfunctype) &&
          offsetof(s_vpi_systf_data, sysfunctype) < offsetof(s_vpi_systf_data, tfname) &&
          offsetof(s_vpi_systf_data, tfname) < offsetof(s_vpi_systf_data, calltf) &&
          offsetof(s_vpi_systf_data, calltf) < offsetof(s_vpi_systf_data, compiletf) &&
          offsetof(s_vpi_systf_data, compiletf) < offsetof(s_vpi_systf_data, sizetf) &&
          offsetof(s_vpi_systf_data, sizetf) < offsetof(s_vpi_systf_data, user_data));
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
