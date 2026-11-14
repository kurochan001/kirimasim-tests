/* VPI application of test_vpi_mcd_printf_signature_format (IEEE 1800-2023 38.28). */
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

static PLI_INT32 on_start(p_cb_data data)
{
    PLI_UINT32 mcd = 1;
    PLI_INT32 n[6];

    (void)data;
    vpi_printf((PLI_BYTE8 *)"type of vpi_mcd_printf: %d\n",
               SAME_TYPE(&vpi_mcd_printf, PLI_INT32 (*)(PLI_UINT32, PLI_BYTE8 *, ...)));
    vpi_printf((PLI_BYTE8 *)"type of a call: %d\n",
               SAME_TYPE(vpi_mcd_printf(mcd, (PLI_BYTE8 *)"unused"), PLI_INT32));
    n[0] = vpi_mcd_printf(mcd, (PLI_BYTE8 *)"[%d|%5d|%-5d|%05d]\n", 42, -42, 7, 31);
    n[1] = vpi_mcd_printf(mcd, (PLI_BYTE8 *)"[%x|%X|%o|%u]\n", 255u, 48879u, 8u, 4000000000u);
    n[2] = vpi_mcd_printf(mcd, (PLI_BYTE8 *)"[%s|%6s|%-6s|%.2s]\n", "ab", "cd", "ef", "ghij");
    n[3] = vpi_mcd_printf(mcd, (PLI_BYTE8 *)"[%c%c|%%|%.3f|%e]\n", 'o', 'k', 2.5, 1250.0);
    n[4] = vpi_mcd_printf(mcd, (PLI_BYTE8 *)"[%+d|% d|%#x|%*d]\n", 5, 6, 255, 4, 9);
    n[5] = vpi_mcd_printf(mcd, (PLI_BYTE8 *)"");
    vpi_printf((PLI_BYTE8 *)"counts: %d %d %d %d %d %d\n", (int)n[0], (int)n[1], (int)n[2],
               (int)n[3], (int)n[4], (int)n[5]);
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
