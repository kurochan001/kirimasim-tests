/* VPI application of test_vpi_named_events (IEEE 1800-2023 37.27). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_named_events"

static vpiHandle find(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name(full, NULL);
}

static int count(PLI_INT32 type, vpiHandle ref)
{
    vpiHandle it = ref ? vpi_iterate(type, ref) : NULL;
    int n = 0;

    if (it != NULL)
        while (vpi_scan(it) != NULL)
            n++;
    return n;
}

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

/* Prints the names of the objects of the given type in the module, sorted. */
static void names(PLI_INT32 type, const char *label)
{
    vpiHandle it = vpi_iterate(type, vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL)), h;
    char list[8][32];
    int n = 0, i;

    /* vpi_get_str can reuse its buffer, so each name is copied. */
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL)
            if (n < 8)
                snprintf(list[n++], sizeof list[0], "%s", vpi_get_str(vpiName, h));
    qsort(list, (size_t)n, sizeof list[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", list[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 events_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle lane = find("lane"), go = find("go"), elem, idx_it, idx;
    s_vpi_value v;

    (void)user_data;
    names(vpiNamedEvent, "named events");
    names(vpiNamedEventArray, "named event arrays");
    elem = lane ? vpi_handle_by_index(lane, 1) : NULL;
    if (elem == NULL) {
        vpi_printf((PLI_BYTE8 *)"lane[1]: not found\n");
    } else {
        idx_it = vpi_iterate(vpiIndex, elem);
        idx = idx_it ? vpi_scan(idx_it) : NULL;
        v.format = vpiIntVal;
        if (idx != NULL)
            vpi_get_value(idx, &v);
        vpi_printf((PLI_BYTE8 *)"%s: named event %d, array member %d, index %d, "
                   "parent is lane %d\n", vpi_get_str(vpiName, elem),
                   vpi_get(vpiType, elem) == vpiNamedEvent, (int)vpi_get(vpiArrayMember, elem),
                   idx ? (int)v.value.integer : -1,
                   (int)vpi_compare_objects(vpi_handle(vpiParent, elem), lane));
        if (idx_it != NULL && idx != NULL)
            vpi_release_handle(idx_it);
    }
    vpi_printf((PLI_BYTE8 *)"go: array member %d, waiting processes %d\n",
               (int)vpi_get(vpiArrayMember, go), count(vpiWaitingProcesses, go));
    vpi_put_value(go, NULL, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 waiting_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"go: waiting processes %d\n", count(vpiWaitingProcesses, find("go")));
    return 0;
}

static void register_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
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
    register_task("$vt_events", events_calltf);
    register_task("$vt_waiting", waiting_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
