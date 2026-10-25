/* VPI application of test_vpi_routines_print_and_flush (IEEE 1800-2023 36.11, Table 36-9). */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Starts the varargs and hands them to vpi_vprintf. */
static PLI_INT32 print_list(const char *format, ...)
{
    va_list ap;
    PLI_INT32 n;
    va_start(ap, format);
    n = vpi_vprintf((PLI_BYTE8 *)format, ap);
    va_end(ap);
    return n;
}

static PLI_INT32 on_start(p_cb_data data)
{
    PLI_INT32 printed, vprinted, flushed;

    (void)data;
    printed = vpi_printf((PLI_BYTE8 *)"vpi_printf: %d %s, %x\n", 7, "apples", 31);
    vprinted = print_list("vpi_vprintf: %d %s, %x\n", 12, "pears", 255);
    flushed = vpi_flush();
    vpi_printf((PLI_BYTE8 *)"returned %d and %d, vpi_flush returned %d\n", (int)printed,
               (int)vprinted, (int)flushed);
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
