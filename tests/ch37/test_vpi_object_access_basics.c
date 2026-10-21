/* VPI application of test_vpi_object_access_basics (IEEE 1800-2023 37.3.1, 37.5). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_object_access_basics"
#define MAX 8
#define LEN 64

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* Prints the names (vpiName) of the objects of an iteration, sorted. */
static void list(const char *label, PLI_INT32 type, vpiHandle ref)
{
    char names[MAX][LEN];
    vpiHandle it = vpi_iterate(type, ref), h;
    int n = 0, i;

    while (it && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (n < MAX)
            snprintf(names[n++], LEN, "%s", s ? s : "(null)");
    }
    qsort(names, n, LEN, by_text);
    vpi_printf("%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    vpi_printf("\n");
}

static vpiHandle find(const char *name)
{
    vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    if (h == NULL)
        vpi_printf("%s: not found\n", name);
    return h;
}

static void full_name(const char *label, vpiHandle h)
{
    PLI_BYTE8 *s = h ? vpi_get_str(vpiFullName, h) : NULL;
    vpi_printf("%s: %s\n", label, s ? s : "(none)");
}

static void top_module(const char *name)
{
    vpiHandle h = find(name);
    if (h != NULL)
        vpi_printf("vpiTopModule of %s: %d\n", name, (int)vpi_get(vpiTopModule, h));
}

static void time_props(const char *label, vpiHandle h)
{
    vpi_printf("time unit and precision of %s: %d %d\n", label, (int)vpi_get(vpiTimeUnit, h),
               (int)vpi_get(vpiTimePrecision, h));
}

static void line(const char *name)
{
    vpiHandle h = find(name);
    if (h != NULL)
        vpi_printf("line of %s: %d\n", name, (int)vpi_get(vpiLineNo, h));
}

static PLI_INT32 access_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top, ua, s1, count, vec, a, call;

    (void)user_data;
    list("top modules", vpiModule, NULL);

    s1 = find(TOP ".ua.s1");
    full_name("s1 found from the top", s1);
    full_name("its module", s1 ? vpi_handle(vpiModule, s1) : NULL);

    top = find(TOP);
    ua = find(TOP ".ua");
    if (top == NULL || ua == NULL)
        return 0;
    list("nets of ua", vpiNet, ua);
    list("instances in the top module", vpiModule, top);
    list("instances in ua", vpiModule, ua);
    top_module(TOP);
    top_module(TOP "_other");
    top_module(TOP ".ua");
    top_module(TOP ".ua.lf");

    count = find(TOP ".count");
    vec = find(TOP ".vec");
    a = find(TOP ".a");
    if (count && vec && a) {
        vpi_printf("vpiSigned: count %d, vec %d\n", (int)vpi_get(vpiSigned, count),
                   (int)vpi_get(vpiSigned, vec));
        vpi_printf("vpiScalar and vpiVector: a %d %d, vec %d %d\n", (int)vpi_get(vpiScalar, a),
                   (int)vpi_get(vpiVector, a), (int)vpi_get(vpiScalar, vec),
                   (int)vpi_get(vpiVector, vec));
    }

    time_props("NULL", NULL);
    time_props(TOP, top);
    time_props(TOP "_other", find(TOP "_other"));

    line(TOP ".ub");
    line(TOP ".tk");
    line(TOP ".fn");
    line(TOP ".blk");
    call = vpi_handle(vpiSysTfCall, NULL);
    if (call != NULL)
        vpi_printf("line of the call of $vt_access: %d\n", (int)vpi_get(vpiLineNo, call));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_access";
    d.calltf = access_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
