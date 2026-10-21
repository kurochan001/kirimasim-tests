/* VPI application of test_vpi_systf_compiletf_arguments (IEEE 1800-2023 36.8.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_WIDTHS 16

static int compiletf_calls;
static int widths[MAX_WIDTHS];
static int width_count;

static int first_argument_width(void)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it != NULL ? vpi_scan(it) : NULL;
    int size = 0;

    if (arg == NULL)
        return 0;
    size = (int)vpi_get(vpiSize, arg);
    vpi_free_object(it);
    return size;
}

static PLI_INT32 width_compiletf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    compiletf_calls++;
    if (width_count < MAX_WIDTHS)
        widths[width_count++] = first_argument_width();
    return 0;
}

static PLI_INT32 width_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_value v;

    (void)user_data;
    v.format = vpiIntVal;
    v.value.integer = first_argument_width();
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    return 0;
}

static int by_width(const void *a, const void *b)
{
    int x = *(const int *)a, y = *(const int *)b;
    return (x > y) - (x < y);
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    qsort(widths, (size_t)width_count, sizeof widths[0], by_width);
    vpi_printf("compiletf calls: %d\n", compiletf_calls);
    vpi_printf("argument widths seen:");
    for (i = 0; i < width_count; i++)
        vpi_printf(" %d", widths[i]);
    vpi_printf("\n");
    return 0;
}

static void add(const char *name, PLI_INT32 (*compiletf)(PLI_BYTE8 *),
                PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)name;
    d.compiletf = compiletf;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_width", width_compiletf, width_calltf);
    add("$vt_report", NULL, report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
