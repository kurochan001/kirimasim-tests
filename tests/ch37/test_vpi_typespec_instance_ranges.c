/* VPI application of test_vpi_typespec_instance_ranges (IEEE 1800-2023 37.25). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_typespec_instance_ranges"
#define MAX 12

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : NULL;
}

static vpiHandle top(void)
{
    return vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
}

static vpiHandle by_name(const char *path)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, path);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1000;
    v.format = vpiIntVal;
    v.value.integer = -1000;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void ranges(vpiHandle h, int order)
{
    vpiHandle it = h != NULL ? vpi_iterate(vpiRange, h) : NULL, r;
    int n = 0;

    vpi_printf((PLI_BYTE8 *)"ranges");
    while (it != NULL && (r = vpi_scan(it)) != NULL) {
        vpi_printf((PLI_BYTE8 *)" %d:%d", int_value(vpi_handle(vpiLeftRange, r)),
                   int_value(vpi_handle(vpiRightRange, r)));
        n++;
    }
    vpi_printf((PLI_BYTE8 *)" %d", n);
    if (order)
        vpi_printf((PLI_BYTE8 *)", left %d right %d",
                   int_value(vpi_handle(vpiLeftRange, h)),
                   int_value(vpi_handle(vpiRightRange, h)));
}

static PLI_INT32 ts_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it, h, ts;
    char names[MAX][48];
    int n = 0, i, j;

    (void)user_data;
    it = vpi_iterate(vpiTypespec, top());
    while (it != NULL && (h = vpi_scan(it)) != NULL && n < MAX) {
        const char *name = sprop(vpiName, h);
        int dup = 0;
        if (name == NULL || name[0] == '\0')
            continue;
        for (i = 0; i < n; i++)
            if (strcmp(names[i], name) == 0)
                dup = 1;
        if (!dup)
            snprintf(names[n++], sizeof names[0], "%s", name);
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (strcmp(names[i], names[j]) > 0) {
                char t[48];
                snprintf(t, sizeof t, "%s", names[i]);
                snprintf(names[i], sizeof names[i], "%s", names[j]);
                snprintf(names[j], sizeof names[j], "%s", t);
            }
    vpi_printf((PLI_BYTE8 *)"instance typespecs: %d", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s%s", i ? "," : " ", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");

    ts = vpi_handle(vpiTypespec, by_name("a"));
    vpi_printf((PLI_BYTE8 *)"arr_t: logic typespec %d, ",
               ts != NULL && vpi_get(vpiType, ts) == vpiLogicTypespec);
    ranges(ts, 1);
    vpi_printf((PLI_BYTE8 *)"\n");
    ts = vpi_handle(vpiTypespec, by_name("w"));
    vpi_printf((PLI_BYTE8 *)"word_t: logic typespec %d, ",
               ts != NULL && vpi_get(vpiType, ts) == vpiLogicTypespec);
    ranges(ts, 0);
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ts";
    d.calltf = ts_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
