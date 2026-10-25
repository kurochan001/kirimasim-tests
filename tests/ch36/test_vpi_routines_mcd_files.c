/* VPI application of test_vpi_routines_mcd_files (IEEE 1800-2023 36.11, Table 36-9). */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Starts the varargs and hands them to vpi_mcd_vprintf. */
static PLI_INT32 mcd_print_list(PLI_UINT32 mcd, const char *format, ...)
{
    va_list ap;
    PLI_INT32 n;
    va_start(ap, format);
    n = vpi_mcd_vprintf(mcd, (PLI_BYTE8 *)format, ap);
    va_end(ap);
    return n;
}

static int one_channel(PLI_UINT32 mcd)
{
    return mcd != 0 && (mcd & (mcd - 1)) == 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    PLI_UINT32 a = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_routines_mcd_files_a.txt");
    PLI_UINT32 b = vpi_mcd_open((PLI_BYTE8 *)"test_vpi_routines_mcd_files_b.txt");
    PLI_UINT32 reserved = 1u | 0x80000000u;
    const char *name;
    char first[64];
    PLI_INT32 printed, vprinted, flushed;
    PLI_UINT32 closed;

    (void)data;
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_open: one channel each %d, not channel 1 or the MSB %d, "
               "two different channels %d\n", one_channel(a) && one_channel(b),
               (a & reserved) == 0 && (b & reserved) == 0, a != b);
    name = vpi_mcd_name(a);
    snprintf(first, sizeof first, "%s", name ? name : "NULL");
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_name of the first: %s\n", first);
    vpi_mcd_printf(a | b, (PLI_BYTE8 *)"to both: %d %x\n", 3, 161);
    printed = vpi_mcd_printf(a, (PLI_BYTE8 *)"only to a: %d\n", 5);
    vprinted = mcd_print_list(b, "only to b: %d %s\n", 42, "beef");
    flushed = vpi_mcd_flush(a | b);
    closed = vpi_mcd_close(a | b);
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_printf to the first returned %d, vpi_mcd_vprintf to the "
               "second returned %d\n", (int)printed, (int)vprinted);
    vpi_printf((PLI_BYTE8 *)"vpi_mcd_flush returned %d, vpi_mcd_close of both returned %u\n",
               (int)flushed, (unsigned)closed);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
