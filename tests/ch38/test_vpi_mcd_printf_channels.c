/* VPI application of test_vpi_mcd_printf_channels (IEEE 1800-2023 38.27, 38.28, 38.29). */
#include <stdarg.h>
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

#define MAX_FILES 40

static const char *const LINE_ONE = "line one: abc| 3.14|7   |01a|\n";
static const char *const LINE_TWO = "line two: ok 50%\n";

static PLI_UINT32 vpi_mcd[MAX_FILES];
static PLI_UINT32 all_vpi;
static int nfiles;

static void file_name(char *buf, int k)
{
    snprintf(buf, 64, "test_vpi_mcd_printf_channels_%02d.txt", k);
}

static PLI_INT32 mcd_write(PLI_UINT32 mcd, const char *format, ...)
{
    va_list ap;
    PLI_INT32 n;

    va_start(ap, format);
    n = vpi_mcd_vprintf(mcd, (PLI_BYTE8 *)format, ap);
    va_end(ap);
    return n;
}

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

/* Reads a whole file into buf; returns its length, or -1 if it cannot be opened. */
static int read_file(const char *name, char *buf, int size)
{
    FILE *f = fopen(name, "r");
    size_t n;

    if (f == NULL)
        return -1;
    n = fread(buf, 1, (size_t)(size - 1), f);
    buf[n] = '\0';
    fclose(f);
    return (int)n;
}

static void print_lines(const char *what, const char *text)
{
    char line[200];
    const char *p = text;

    while (*p != '\0') {
        size_t n = strcspn(p, "\n");
        if (n >= sizeof line)
            n = sizeof line - 1;
        memcpy(line, p, n);
        line[n] = '\0';
        vpi_printf((PLI_BYTE8 *)"%s: %s\n", what, line);
        p += n;
        if (*p == '\n')
            p++;
    }
}

static PLI_INT32 open_all_calltf(PLI_BYTE8 *user_data)
{
    PLI_UINT32 arg[1], m, seen = 0;
    int k, one_bit = 1, no_reserved = 1, distinct = 1;
    char name[64];
    s_vpi_value v;

    (void)user_data;
    if (!read_arguments(arg, 1)) {
        vpi_printf((PLI_BYTE8 *)"wrong arguments\n");
        return 0;
    }
    nfiles = 0;
    for (k = 0; k < MAX_FILES; k++) {
        file_name(name, k);
        m = vpi_mcd_open(name);
        if (m == 0)
            break;
        vpi_mcd[nfiles++] = m;
        if ((m & (m - 1)) != 0)
            one_bit = 0;
        if ((m & 0x80000001u) != 0)
            no_reserved = 0;
        if (((seen | arg[0]) & m) != 0)
            distinct = 0;
        seen |= m;
    }
    all_vpi = seen;
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_open opened %d files, then returned 0\n", nfiles);
    vpi_printf((PLI_BYTE8 *)"one bit each: %d, never bit 0 or bit 31: %d, "
                            "all different and not fm: %d\n",
               one_bit, no_reserved, distinct);
    vpi_printf((PLI_BYTE8 *)"with fm they set exactly bits 1 to 30: %d\n",
               (int)((seen | arg[0]) == 0x7FFFFFFEu));
    v.format = vpiIntVal;
    v.value.integer = nfiles > 0 ? (PLI_INT32)vpi_mcd[0] : 0;
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 write_calltf(PLI_BYTE8 *user_data)
{
    PLI_UINT32 arg[2], all;
    PLI_INT32 n1, n2;

    (void)user_data;
    if (!read_arguments(arg, 2)) {
        vpi_printf((PLI_BYTE8 *)"wrong arguments\n");
        return 0;
    }
    all = 1u | arg[0] | all_vpi;
    n1 = vpi_mcd_printf(all, (PLI_BYTE8 *)"line one: %s|%5.2f|%-4d|%03x|\n", "abc", 3.14159, 7,
                        26);
    n2 = mcd_write(all, "line two: %c%c %d%%\n", 'o', 'k', 50);
    vpi_mcd_printf(arg[1], (PLI_BYTE8 *)"written to the fd by vpi_mcd_printf\n");
    mcd_write(arg[1], "written to the fd by vpi_mcd_vprintf\n");
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_printf returned %d, vpi_mcd_vprintf returned %d\n", (int)n1,
               (int)n2);
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_printf returns PLI_INT32: %d\n",
               SAME_TYPE(vpi_mcd_printf(0, (PLI_BYTE8 *)""), PLI_INT32));
    return 0;
}

static PLI_INT32 close_all_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_close of the %d files returned %u\n", nfiles,
               (unsigned)vpi_mcd_close(all_vpi));
    return 0;
}

static PLI_INT32 check_calltf(PLI_BYTE8 *user_data)
{
    char name[64], text[1024], both[200];
    int k, same = 0;
    PLI_INT32 after, after_v;

    (void)user_data;
    if (nfiles < 3) {
        vpi_printf((PLI_BYTE8 *)"too few files\n");
        return 0;
    }
    after = vpi_mcd_printf(vpi_mcd[1], (PLI_BYTE8 *)"written after the close\n");
    after_v = mcd_write(vpi_mcd[2], "written after the close by %s\n", "vpi_mcd_vprintf");
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_printf and vpi_mcd_vprintf to a closed channel "
                            "returned EOF: %d %d\n",
               (int)(after == EOF), (int)(after_v == EOF));
    snprintf(both, sizeof both, "%s%s", LINE_ONE, LINE_TWO);
    file_name(name, 0);
    if (read_file(name, text, sizeof text) >= 0)
        print_lines("file 00", text);
    for (k = 1; k < nfiles; k++) {
        file_name(name, k);
        if (read_file(name, text, sizeof text) >= 0 && strcmp(text, both) == 0)
            same++;
    }
    vpi_printf((PLI_BYTE8 *)"files 01 to %02d holding just the two lines: %d\n", nfiles - 1, same);
    if (read_file("test_vpi_mcd_printf_channels_fm.txt", text, sizeof text) >= 0)
        print_lines("fm", text);
    vpi_printf((PLI_BYTE8 *)"characters in the file of the fd: %d\n",
               read_file("test_vpi_mcd_printf_channels_fd.txt", text, sizeof text));
    return 0;
}

static void add(const char *name, PLI_INT32 type, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = type;
    d.sysfunctype = type == vpiSysFunc ? vpiIntFunc : 0;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_open_all", vpiSysFunc, open_all_calltf);
    add("$vt_write", vpiSysTask, write_calltf);
    add("$vt_close_all", vpiSysTask, close_all_calltf);
    add("$vt_check", vpiSysTask, check_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
