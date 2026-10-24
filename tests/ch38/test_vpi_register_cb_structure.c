/* VPI application of test_vpi_register_cb_structure (IEEE 1800-2023 38.36, 38.8). */
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

#define TOP "test_vpi_register_cb_structure"
#define CHECK(what, ok) vpi_printf((PLI_BYTE8 *)"%s %d\n", what, (int)(ok))
/* No parentheses around the member access: decltype gives its declared type. */
#define FIELD(f) ((s_cb_data *)0)->f
#define AT(f) offsetof(s_cb_data, f)

typedef PLI_INT32 (*routine_t)(struct t_cb_data *);

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_event_or_time(p_cb_data cb)
{
    vpi_printf((PLI_BYTE8 *)"on_event_or_time: %s at %d\n", cb->user_data, now());
    return 0;
}

static PLI_INT32 on_end(p_cb_data cb)
{
    vpi_printf((PLI_BYTE8 *)"on_end: %s at %d\n", cb->user_data, now());
    return 0;
}

static void registered(const char *what, vpiHandle h)
{
    vpi_printf((PLI_BYTE8 *)"%s: handle is a vpiCallback %d\n", what,
               h != NULL && vpi_get(vpiType, h) == vpiCallback);
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time sim_time, delay;
    static s_vpi_value int_value;
    s_cb_data cb;

    (void)data;
    CHECK("p_cb_data points to s_cb_data (struct t_cb_data)",
          SAME_TYPE((p_cb_data)0, struct t_cb_data *) &&
          SAME_TYPE((s_cb_data *)0, struct t_cb_data *));
    CHECK("reason PLI_INT32", SAME_TYPE(FIELD(reason), PLI_INT32));
    CHECK("cb_rtn PLI_INT32 (*)(struct t_cb_data *)", SAME_TYPE(FIELD(cb_rtn), routine_t));
    CHECK("obj vpiHandle", SAME_TYPE(FIELD(obj), vpiHandle));
    CHECK("time p_vpi_time", SAME_TYPE(FIELD(time), p_vpi_time));
    CHECK("value p_vpi_value", SAME_TYPE(FIELD(value), p_vpi_value));
    CHECK("index PLI_INT32", SAME_TYPE(FIELD(index), PLI_INT32));
    CHECK("user_data PLI_BYTE8 *", SAME_TYPE(FIELD(user_data), PLI_BYTE8 *));
    CHECK("order reason cb_rtn obj time value index user_data",
          AT(reason) < AT(cb_rtn) && AT(cb_rtn) < AT(obj) && AT(obj) < AT(time) &&
          AT(time) < AT(value) && AT(value) < AT(index) && AT(index) < AT(user_data));
    CHECK("vpi_register_cb vpiHandle (*)(p_cb_data)",
          SAME_TYPE(&vpi_register_cb, vpiHandle (*)(p_cb_data)));

    sim_time.type = vpiSimTime;
    int_value.format = vpiIntVal;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbValueChange;
    cb.cb_rtn = on_event_or_time;
    cb.obj = vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL);
    cb.time = &sim_time;
    cb.value = &int_value;
    cb.user_data = (PLI_BYTE8 *)"cbValueChange on r";
    registered("cbValueChange (simulation event)", vpi_register_cb(&cb));

    delay.type = vpiSimTime;
    delay.high = 0;
    delay.low = 5;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_event_or_time;
    cb.time = &delay;
    cb.user_data = (PLI_BYTE8 *)"cbAfterDelay 5";
    registered("cbAfterDelay (simulation time)", vpi_register_cb(&cb));

    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfSimulation;
    cb.cb_rtn = on_end;
    cb.user_data = (PLI_BYTE8 *)"cbEndOfSimulation";
    registered("cbEndOfSimulation (simulator action)", vpi_register_cb(&cb));
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
