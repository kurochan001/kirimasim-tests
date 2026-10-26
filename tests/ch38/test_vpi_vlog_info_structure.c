/* VPI application of test_vpi_vlog_info_structure (IEEE 1800-2023 38.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
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

static int terminated(const char *s)
{
    return s != NULL && memchr(s, '\0', 4096) != NULL;
}

static PLI_INT32 on_start(p_cb_data data)
{
    s_vpi_vlog_info info;
    PLI_INT32 ok;
    int order, strings = 1, k;

    (void)data;
    memset(&info, 0, sizeof info);
    ok = vpi_get_vlog_info(&info);
    order = offsetof(s_vpi_vlog_info, argc) < offsetof(s_vpi_vlog_info, argv)
            && offsetof(s_vpi_vlog_info, argv) < offsetof(s_vpi_vlog_info, product)
            && offsetof(s_vpi_vlog_info, product) < offsetof(s_vpi_vlog_info, version);
    for (k = 0; k < info.argc; k++)
        if (!terminated(info.argv != NULL ? info.argv[k] : NULL))
            strings = 0;
    vpi_printf("argc PLI_INT32 %d\n", SAME_TYPE(info.argc, PLI_INT32));
    vpi_printf("argv PLI_BYTE8 ** %d\n", SAME_TYPE(info.argv, PLI_BYTE8 **));
    vpi_printf("product PLI_BYTE8 * %d\n", SAME_TYPE(info.product, PLI_BYTE8 *));
    vpi_printf("version PLI_BYTE8 * %d\n", SAME_TYPE(info.version, PLI_BYTE8 *));
    vpi_printf("field order argc argv product version %d\n", order);
    vpi_printf("vpi_get_vlog_info returns %d, argc at least 3 %d\n", (int)ok,
               info.argc >= 3 ? 1 : 0);
    vpi_printf("every argv entry is a string %d\n", strings);
    vpi_printf("product is a nonempty string %d\n",
               terminated(info.product) && info.product[0] != '\0' ? 1 : 0);
    vpi_printf("version is a nonempty string %d\n",
               terminated(info.version) && info.version[0] != '\0' ? 1 : 0);
    vpi_printf("argv[0] is a nonempty tool name, not a plusarg %d\n",
               terminated(info.argv[0]) && info.argv[0][0] != '\0'
               && info.argv[0][0] != '+' ? 1 : 0);
    vpi_printf("last two entries are the plusargs in order %d\n",
               info.argc >= 2
               && strcmp(info.argv[info.argc - 2], "+vt_alpha") == 0
               && strcmp(info.argv[info.argc - 1], "+vt_count=3") == 0 ? 1 : 0);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
