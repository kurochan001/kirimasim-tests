/* VPI application of test_vpi_mcd_close_channels (IEEE 1800-2023 38.24). */
#include <stdio.h>
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

static int read_arguments(PLI_UINT32 *values, int count)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg;
    s_vpi_value v;
    int k = 0;

    while (it != NULL && (arg = vpi_scan(it)) != NULL) {
        v.format = vpiIntVal;
        vpi_get_value(arg, &v);
        if (k < count)
            values[k] = (PLI_UINT32)v.value.integer;
        k++;
    }
    return k == count;
}

/* Prints each line of a file, prefixed with its short name. */
static void show_file(const char *what, const char *name)
{
    char line[200];
    FILE *f = fopen(name, "r");

    if (f == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: cannot be read\n", what);
        return;
    }
    while (fgets(line, sizeof line, f) != NULL)
        vpi_printf((PLI_BYTE8 *)"%s: %s", what, line);
    fclose(f);
}

static PLI_INT32 close_calltf(PLI_BYTE8 *user_data)
{
    PLI_UINT32 arg[2], a, b, c, r_ab, r_1c, r_fm, r_fd;

    (void)user_data;
    if (!read_arguments(arg, 2)) {
        vpi_printf((PLI_BYTE8 *)"wrong arguments\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_close is PLI_UINT32 (*)(PLI_UINT32): %d\n",
               SAME_TYPE(&vpi_mcd_close, PLI_UINT32 (*)(PLI_UINT32)));
    a = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_close_channels_a.txt");
    b = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_close_channels_b.txt");
    c = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_close_channels_c.txt");
    if (a == 0 || b == 0 || c == 0) {
        vpi_printf((PLI_BYTE8 *)"vpi_mcd_open failed\n");
        return 0;
    }
    vpi_mcd_printf(a | b | c, (PLI_BYTE8 *)"first line\n");
    r_ab = vpi_mcd_close(a | b);
    vpi_mcd_printf(a | b | c, (PLI_BYTE8 *)"second line, after a and b were closed\n");
    r_1c = vpi_mcd_close(1u | c);
    vpi_mcd_printf(1u, (PLI_BYTE8 *)"channel 1 is still open\n");
    vpi_mcd_printf(c, (PLI_BYTE8 *)"third line, after c was closed\n");
    r_fm = vpi_mcd_close(arg[0]);
    r_fd = vpi_mcd_close(arg[1]);
    vpi_printf((PLI_BYTE8 *)"close a|b: %u, close 1|c: %u, close fm: %u, close fd: %u\n",
               (unsigned)r_ab, (unsigned)r_1c, (unsigned)r_fm, (unsigned)r_fd);
    return 0;
}

static PLI_INT32 check_calltf(PLI_BYTE8 *user_data)
{
    PLI_UINT32 arg[2];

    (void)user_data;
    if (!read_arguments(arg, 2)) {
        vpi_printf((PLI_BYTE8 *)"wrong arguments\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_name of fm and fd after the close is NULL: %d %d\n",
               (int)(vpi_mcd_name(arg[0]) == NULL), (int)(vpi_mcd_name(arg[1]) == NULL));
    show_file("a", "test_vpi_mcd_close_channels_a.txt");
    show_file("b", "test_vpi_mcd_close_channels_b.txt");
    show_file("c", "test_vpi_mcd_close_channels_c.txt");
    show_file("fm", "test_vpi_mcd_close_channels_fm.txt");
    show_file("fd", "test_vpi_mcd_close_channels_fd.txt");
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
    add("$vt_close", close_calltf);
    add("$vt_check", check_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
