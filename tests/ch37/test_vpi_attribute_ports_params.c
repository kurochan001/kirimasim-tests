/* VPI application of test_vpi_attribute_ports_params (IEEE 1800-2023 37.83). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_attribute_ports_params"
#define MAX_LINES 16

static char lines[MAX_LINES][128];
static int line_count;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *str_or(PLI_INT32 prop, vpiHandle h, const char *fallback)
{
    const char *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    return s != NULL ? s : fallback;
}

static void add_line(const char *text)
{
    if (line_count < MAX_LINES)
        snprintf(lines[line_count++], sizeof lines[0], "%s", text);
}

/* Records "where: base name of vpiDefFile line vpiDefLineNo" for the attribute a. */
static void location(const char *label, const char *attr, vpiHandle a)
{
    char text[128];
    const char *file = vpi_get_str(vpiDefFile, a), *base;

    base = file != NULL ? strrchr(file, '/') : NULL;
    base = base != NULL ? base + 1 : (file != NULL ? file : "NULL");
    snprintf(text, sizeof text, "location of %s of %s: %s line %d", attr, label, base,
             (int)vpi_get(vpiDefLineNo, a));
    add_line(text);
}

/* Records "label: name=value (vpiParent is it: 1), ..." for the attributes of obj. */
static void attributes(const char *label, vpiHandle obj)
{
    char text[128], one[64];
    vpiHandle it, a, parent;
    s_vpi_value v;
    int n = 0;

    snprintf(text, sizeof text, "%s:", label);
    it = vpi_iterate(vpiAttribute, obj);
    while (it != NULL && (a = vpi_scan(it)) != NULL) {
        v.format = vpiIntVal;
        vpi_get_value(a, &v);
        parent = vpi_handle(vpiParent, a);
        snprintf(one, sizeof one, "%s %s=%d (vpiParent is it: %d)", n ? "," : "",
                 str_or(vpiName, a, "(no name)"), (int)v.value.integer,
                 parent != NULL && vpi_compare_objects(parent, obj) ? 1 : 0);
        strncat(text, one, sizeof text - strlen(text) - 1);
        location(label, str_or(vpiName, a, "(no name)"), a);
        n++;
    }
    if (n == 0)
        strncat(text, " none", sizeof text - strlen(text) - 1);
    add_line(text);
}

static PLI_INT32 start_of_simulation(p_cb_data data)
{
    vpiHandle u, it, h, w, a;
    char label[64];
    int i;

    (void)data;
    u = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);
    if (u == NULL) {
        vpi_printf((PLI_BYTE8 *)"u not found\n");
        return 0;
    }
    it = vpi_iterate(vpiPort, u);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        snprintf(label, sizeof label, "port %s", str_or(vpiName, h, "(no name)"));
        attributes(label, h);
    }
    it = vpi_iterate(vpiParamAssign, u);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        snprintf(label, sizeof label, "param assign %s",
                 str_or(vpiName, vpi_handle(vpiLhs, h), "(no name)"));
        attributes(label, h);
    }
    w = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u.w", NULL);
    it = w != NULL ? vpi_iterate(vpiAttribute, w) : NULL;
    while (it != NULL && (a = vpi_scan(it)) != NULL)
        location("net w", str_or(vpiName, a, "(no name)"), a);
    qsort(lines, (size_t)line_count, sizeof lines[0], compare);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
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
