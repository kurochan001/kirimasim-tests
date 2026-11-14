/* VPI application of test_vpi_compilation_unit_iteration (IEEE 1800-2023 3.12.1, 37.10). */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

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

/* vpi_get_str reuses its buffer (38.11), so the full name is copied. */
static void full_name(vpiHandle h, char *buf, size_t size)
{
    const char *s = vpi_get_str(vpiFullName, h);

    snprintf(buf, size, "%s", s != NULL ? s : "(no name)");
}

static void list_unit(vpiHandle unit)
{
    vpiHandle it, h;
    s_vpi_value v;
    char name[96];

    it = vpi_iterate(vpiVariables, unit);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        full_name(h, name, sizeof name);
        v.format = vpiIntVal;
        vpi_get_value(h, &v);
        add_line("unit variable %s = %d", name, (int)v.value.integer);
    }
    it = vpi_iterate(vpiTaskFunc, unit);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        full_name(h, name, sizeof name);
        add_line("unit %s %s", vpi_get(vpiType, h) == vpiFunction ? "function" : "task", name);
    }
}

static PLI_INT32 units_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it, inst;
    int units = 0, i;

    (void)user_data;
    it = vpi_iterate(vpiInstance, NULL);
    while (it != NULL && (inst = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, inst) == vpiPackage && vpi_get(vpiUnit, inst) == 1) {
            units++;
            list_unit(inst);
        }
    }
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"compilation units: %d\n", units);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data tf;

    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask;
    tf.tfname = (PLI_BYTE8 *)"$vt_units";
    tf.calltf = units_calltf;
    vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
