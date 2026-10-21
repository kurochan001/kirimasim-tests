/* VPI application of test_vpi_mcd_name_flush_fopen (IEEE 1800-2023 38.26, 38.25, 38.29). */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_UINT32 mcd_c;

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

static const char *name_of(PLI_UINT32 cd)
{
    PLI_BYTE8 *name = vpi_mcd_name(cd);
    return name ? name : "NULL";
}

static PLI_INT32 files_calltf(PLI_BYTE8 *user_data)
{
    PLI_UINT32 arg[2], used, unused = 0;
    PLI_INT32 to_a, to_c;
    int bit;

    (void)user_data;
    if (!read_arguments(arg, 2)) {
        vpi_printf("wrong arguments\n");
        return 0;
    }
    vpi_printf("name of the $fopen mcd: %s\n", name_of(arg[0]));
    vpi_printf("name of the $fopen fd: %s\n", name_of(arg[1]));
    mcd_c = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_mcd_name_flush_fopen_c.txt");
    if (mcd_c == 0) {
        vpi_printf("vpi_mcd_open failed\n");
        return 0;
    }
    used = 1 | arg[0] | mcd_c;
    for (bit = 30; bit > 0 && unused == 0; bit--)
        if ((used & (1u << bit)) == 0)
            unused = 1u << bit;
    vpi_printf("name of a channel that is not open: %s\n", name_of(unused));
    to_a = mcd_write(arg[0], "line for a: %d\n", 7);
    to_c = mcd_write(mcd_c, "line for c: %s\n", "seven");
    vpi_printf("vpi_mcd_vprintf wrote %d characters to a and %d to c\n", (int)to_a, (int)to_c);
    vpi_printf("vpi_mcd_flush of both returns %d\n", (int)vpi_mcd_flush(arg[0] | mcd_c));
    return 0;
}

static PLI_INT32 closed_calltf(PLI_BYTE8 *user_data)
{
    PLI_UINT32 arg[1];

    (void)user_data;
    if (!read_arguments(arg, 1)) {
        vpi_printf("wrong arguments\n");
        return 0;
    }
    vpi_printf("name of the fd after $fclose: %s\n", name_of(arg[0]));
    vpi_printf("vpi_mcd_close of c returns %d\n", (int)vpi_mcd_close(mcd_c));
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
    add("$vt_files", files_calltf);
    add("$vt_closed", closed_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
