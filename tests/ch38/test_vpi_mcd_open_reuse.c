/* VPI application of test_vpi_mcd_open_reuse (IEEE 1800-2023 38.27, 38.25). */
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

static PLI_INT32 open_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it == NULL ? NULL : vpi_scan(it);
    PLI_UINT32 fm, a1, a2, m, bad, unused = 0;
    PLI_INT32 flushed, not_flushed;
    s_vpi_value v;
    int bit;

    (void)user_data;
    if (arg == NULL) {
        vpi_printf((PLI_BYTE8 *)"no argument\n");
        return 0;
    }
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    fm = (PLI_UINT32)v.value.integer;

    a1 = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_open_reuse_a.txt");
    a2 = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_open_reuse_a.txt");
    m = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_open_reuse_m.txt");
    bad = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_open_reuse_missing_dir/x.txt");
    vpi_printf((PLI_BYTE8 *)"first vpi_mcd_open of a is nonzero: %d\n", (int)(a1 != 0));
    vpi_printf((PLI_BYTE8 *)"second vpi_mcd_open of a returned the first descriptor: %d\n",
               (int)(a2 == a1));
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_open of the file of fm returned fm: %d\n", (int)(m == fm));
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_open in a missing directory returned %u\n", (unsigned)bad);

    vpi_printf((PLI_BYTE8 *)"vpi_mcd_flush is PLI_INT32 (*)(PLI_UINT32): %d\n",
               SAME_TYPE(&vpi_mcd_flush, PLI_INT32 (*)(PLI_UINT32)));
    vpi_mcd_printf(a1, (PLI_BYTE8 *)"a line to flush\n");
    flushed = vpi_mcd_flush(a1);
    for (bit = 30; bit > 0 && unused == 0; bit--)
        if (((1u | a1 | fm) & (1u << bit)) == 0)
            unused = 1u << bit;
    not_flushed = vpi_mcd_flush(unused);
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_flush of a returned %d, "
                            "of a channel with no file nonzero: %d\n",
               (int)flushed, (int)(not_flushed != 0));
    vpi_mcd_close(a1);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_open";
    d.calltf = open_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
