/* VPI application of test_vpi_printf_return_counts (IEEE 1800-2023 38.30, 38.41, 38.5). */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 by_vprintf(const char *format, ...)
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
    PLI_INT32 p[5], v[5], first, flushed, second;

    (void)data;
    p[0] = vpi_printf((PLI_BYTE8 *)"[%d|%5d|%-4d|]\n", -42, 7, 3);
    v[0] = by_vprintf("[%d|%5d|%-4d|]\n", -42, 7, 3);
    p[1] = vpi_printf((PLI_BYTE8 *)"hex=%x oct=%o %c %d%%\n", 255, 8, 'Z', 100);
    v[1] = by_vprintf("hex=%x oct=%o %c %d%%\n", 255, 8, 'Z', 100);
    p[2] = vpi_printf((PLI_BYTE8 *)"%.3f %e\n", 2.5, 1500.0);
    v[2] = by_vprintf("%.3f %e\n", 2.5, 1500.0);
    p[3] = vpi_printf((PLI_BYTE8 *)"two\nlines\n");
    v[3] = by_vprintf("two\nlines\n");
    p[4] = vpi_printf((PLI_BYTE8 *)"%s", "");
    v[4] = by_vprintf("%s", "");
    vpi_printf((PLI_BYTE8 *)"vpi_printf: %d %d %d %d %d\n", (int)p[0], (int)p[1], (int)p[2],
               (int)p[3], (int)p[4]);
    vpi_printf((PLI_BYTE8 *)"vpi_vprintf: %d %d %d %d %d\n", (int)v[0], (int)v[1], (int)v[2],
               (int)v[3], (int)v[4]);

    first = vpi_printf((PLI_BYTE8 *)"first part, ");
    flushed = vpi_flush();
    second = vpi_printf((PLI_BYTE8 *)"second part\n");
    vpi_printf((PLI_BYTE8 *)"parts: %d and %d characters, vpi_flush returned %d\n", (int)first,
               (int)second, (int)flushed);
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
