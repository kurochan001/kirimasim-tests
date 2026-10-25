/* VPI application of test_vpi_tagged_relation_access (IEEE 1800-2023 37.4.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_tagged_relation_access"
#define MAX 8
#define LEN 64

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static int by_value(const void *a, const void *b)
{
    int x = *(const int *)a, y = *(const int *)b;
    return (x > y) - (x < y);
}

static vpiHandle find(const char *name)
{
    char full[160];
    vpiHandle h;
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", full);
    return h;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

/* One-to-one relations with a tag: vpi_handle(tag, ref). */
static void range_of(const char *name)
{
    vpiHandle ref = find(name), l, r;
    if (ref == NULL)
        return;
    l = vpi_handle(vpiLeftRange, ref);
    r = vpi_handle(vpiRightRange, ref);
    vpi_printf((PLI_BYTE8 *)"%s: vpiLeftRange ", name);
    if (l != NULL)
        vpi_printf((PLI_BYTE8 *)"%d", int_value(l));
    else
        vpi_printf((PLI_BYTE8 *)"(none)");
    vpi_printf((PLI_BYTE8 *)", vpiRightRange ");
    if (r != NULL)
        vpi_printf((PLI_BYTE8 *)"%d", int_value(r));
    else
        vpi_printf((PLI_BYTE8 *)"(none)");
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void parent_of_bit(void)
{
    vpiHandle w = find("w"), bit, parent;
    PLI_BYTE8 *s;
    if (w == NULL)
        return;
    bit = vpi_handle_by_index(w, 5);
    if (bit == NULL) {
        vpi_printf((PLI_BYTE8 *)"w[5]: not found\n");
        return;
    }
    parent = vpi_handle(vpiParent, bit);
    s = parent != NULL ? vpi_get_str(vpiFullName, parent) : NULL;
    vpi_printf((PLI_BYTE8 *)"w[5] = %d: vpiParent %s\n", int_value(bit), s ? s : "(none)");
}

/* One-to-many relations with a tag: vpi_iterate(tag, ref), then vpi_scan. */
static void arguments_of(vpiHandle call)
{
    int values[MAX];
    vpiHandle it = call != NULL ? vpi_iterate(vpiArgument, call) : NULL, a;
    int n = 0, i;

    while (it != NULL && (a = vpi_scan(it)) != NULL)
        if (n < MAX)
            values[n++] = int_value(a);
    qsort(values, n, sizeof values[0], by_value);
    vpi_printf((PLI_BYTE8 *)"vpiArgument of the call (%d):", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %d", values[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void scopes_of(const char *name)
{
    char names[MAX][LEN];
    vpiHandle ref = find(name), it, h;
    int n = 0, i;

    if (ref == NULL)
        return;
    it = vpi_iterate(vpiInternalScope, ref);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (n < MAX)
            snprintf(names[n++], LEN, "%s", s ? s : "(null)");
    }
    qsort(names, n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"vpiInternalScope of %s (%d):", name, n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 tags_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    range_of("w");
    range_of("v");
    parent_of_bit();
    arguments_of(vpi_handle(vpiSysTfCall, NULL));
    scopes_of("outer");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_tags";
    d.calltf = tags_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
