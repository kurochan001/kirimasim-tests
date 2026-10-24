/* VPI application of test_vpi_userdata_failures (IEEE 1800-2023 38.33, 38.14). */
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

static int counters[2];
static int stored[2];

static PLI_INT32 keep_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    s_vpi_value v;
    int *mine;
    int place;

    (void)user_data;
    v.format = vpiIntVal;
    vpi_get_value(vpi_scan(it), &v);
    vpi_release_handle(it);
    place = (int)v.value.integer - 1;
    mine = (int *)vpi_get_userdata(call);
    if (mine == NULL && !stored[place]) {
        PLI_INT32 ok = vpi_put_userdata(call, &counters[place]);
        stored[place] = 1;
        vpi_printf((PLI_BYTE8 *)"$vt_keep(%d): nothing stored yet, vpi_put_userdata returns %d\n",
                   place + 1, (int)ok);
        mine = (int *)vpi_get_userdata(call);
    }
    if (mine == NULL) {
        vpi_printf((PLI_BYTE8 *)"$vt_keep(%d): vpi_get_userdata returns NULL\n", place + 1);
        return 0;
    }
    ++*mine;
    vpi_printf((PLI_BYTE8 *)"$vt_keep(%d): counter of place %d, now %d\n", place + 1,
               mine == &counters[0] ? 1 : mine == &counters[1] ? 2 : 0, *mine);
    return 0;
}

static PLI_INT32 misuse_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle var = vpi_scan(it);
    static int unused;

    (void)user_data;
    vpi_release_handle(it);
    vpi_printf((PLI_BYTE8 *)"vpi_put_userdata PLI_INT32 (*)(vpiHandle, void *) %d\n",
               SAME_TYPE(&vpi_put_userdata, PLI_INT32 (*)(vpiHandle, void *)));
    vpi_printf((PLI_BYTE8 *)"vpi_get_userdata void *(*)(vpiHandle) %d\n",
               SAME_TYPE(&vpi_get_userdata, void *(*)(vpiHandle)));
    vpi_printf((PLI_BYTE8 *)"$vt_misuse: vpi_put_userdata on a variable returns %d\n",
               (int)vpi_put_userdata(var, &unused));
    vpi_printf((PLI_BYTE8 *)"$vt_misuse: vpi_get_userdata on a variable returns %s\n",
               vpi_get_userdata(var) == NULL ? "NULL" : "data");
    vpi_printf((PLI_BYTE8 *)"$vt_misuse: vpi_get_userdata of its own call returns %s\n",
               vpi_get_userdata(call) == NULL ? "NULL" : "data");
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_keep", keep_calltf);
    add("$vt_misuse", misuse_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
