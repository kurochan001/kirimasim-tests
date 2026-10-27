/* VPI application of test_vpi_attribute_value_types (IEEE 1800-2023 5.12). */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_attribute_value_types"
#define MAX_LINES 16
#define LINE_SIZE 128

static char lines[MAX_LINES][LINE_SIZE];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void add_line(const char *fmt, ...)
{
    va_list ap;

    if (line_count == MAX_LINES)
        return;
    va_start(ap, fmt);
    vsnprintf(lines[line_count], sizeof lines[0], fmt, ap);
    va_end(ap);
    line_count++;
}

static const char *format_name(PLI_INT32 f)
{
    return f == vpiIntVal ? "vpiIntVal" : f == vpiRealVal ? "vpiRealVal"
           : f == vpiVectorVal ? "vpiVectorVal" : f == vpiScalarVal ? "vpiScalarVal"
           : f == vpiStringVal ? "vpiStringVal" : "another format";
}

/* The value of the attribute in the format of the type of its expression. */
static void show_value(const char *name, vpiHandle a)
{
    s_vpi_value v;

    v.format = vpiObjTypeVal;
    vpi_get_value(a, &v);
    if (v.format == vpiIntVal)
        add_line("%s: format vpiIntVal, integer %d", name, (int)v.value.integer);
    else if (v.format == vpiRealVal)
        add_line("%s: format vpiRealVal, real %.2f", name, v.value.real);
    else if (v.format == vpiVectorVal)
        add_line("%s: format vpiVectorVal, aval %x bval %x", name,
                 (unsigned)v.value.vector[0].aval, (unsigned)v.value.vector[0].bval);
    else if (v.format == vpiStringVal)
        add_line("%s: format vpiStringVal, string %s", name,
                 v.value.str != NULL ? v.value.str : "(null)");
    else
        add_line("%s: format %s", name, format_name(v.format));
}

/* The characters of the string literal attribute, as 5.9 gives them. */
static void show_string(const char *name, vpiHandle a)
{
    s_vpi_value v;

    v.format = vpiStringVal;
    vpi_get_value(a, &v);
    add_line("%s: string %s", name, v.value.str != NULL ? v.value.str : "(null)");
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle iv, it, a;
    const char *name;
    int n = 0, i;

    (void)data;
    iv = vpi_handle_by_name((PLI_BYTE8 *)TOP ".iv", NULL);
    if (iv == NULL) {
        vpi_printf((PLI_BYTE8 *)"variable iv: not found\n");
        return 0;
    }
    it = vpi_iterate(vpiAttribute, iv);
    while (it != NULL && (a = vpi_scan(it)) != NULL) {
        name = vpi_get_str(vpiName, a);
        if (name == NULL)
            name = "(no name)";
        show_value(name, a);
        if (strcmp(name, "text") == 0)
            show_string(name, a);
        n++;
    }
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"attributes: %d\n", n);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;

    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = start_of_simulation;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
