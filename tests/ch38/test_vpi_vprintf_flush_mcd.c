/* VPI application of test_vpi_vprintf_flush_mcd (IEEE 1800-2023 38.41, 38.29, 38.5). */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 say(const char *format, ...)
{
    va_list ap;
    PLI_INT32 n;

    va_start(ap, format);
    n = vpi_vprintf((PLI_BYTE8 *)format, ap);
    va_end(ap);
    return n;
}

static PLI_INT32 say_to(PLI_UINT32 mcd, const char *format, ...)
{
    va_list ap;
    PLI_INT32 n;

    va_start(ap, format);
    n = vpi_mcd_vprintf(mcd, (PLI_BYTE8 *)format, ap);
    va_end(ap);
    return n;
}

static PLI_INT32 say_calltf(PLI_BYTE8 *user_data)
{
    PLI_INT32 n;

    (void)user_data;
    n = say("value %d and %s\n", 42, "text");
    vpi_printf("vpi_vprintf wrote %d characters\n", (int)n);
    vpi_printf("vpi_flush returned %d\n", (int)vpi_flush());
    return 0;
}

static PLI_INT32 write_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it ? vpi_scan(it) : NULL;
    s_vpi_value v;
    PLI_INT32 n;

    (void)user_data;
    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    n = say_to((PLI_UINT32)v.value.integer, "line %d of %s\n", 7, "the file");
    vpi_printf("vpi_mcd_vprintf wrote %d characters\n", (int)n);
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
    add("$vt_say", say_calltf);
    add("$vt_write", write_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
