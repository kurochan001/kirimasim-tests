/* VPI application of test_vpi_mailbox_semaphore_waiters (IEEE 1800-2023 37.33). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_mailbox_semaphore_waiters"
#define MAX 8

static vpiHandle object_of(const char *name)
{
    char full[96];
    vpiHandle var;
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    var = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    return var != NULL ? vpi_handle(vpiClassObj, var) : NULL;
}

static int by_value(const void *x, const void *y)
{
    int a = *(const int *)x, b = *(const int *)y;
    return (a > b) - (a < b);
}

/* The values of the messages, sorted. */
static void messages(vpiHandle obj, const char *label)
{
    vpiHandle it = obj != NULL ? vpi_iterate(vpiMessages, obj) : NULL, h;
    int values[MAX], n = 0, i;
    s_vpi_value v;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        v.format = vpiIntVal;
        vpi_get_value(h, &v);
        if (n < MAX)
            values[n] = (int)v.value.integer;
        n++;
    }
    if (n > MAX)
        n = MAX;
    qsort(values, (size_t)n, sizeof values[0], by_value);
    vpi_printf((PLI_BYTE8 *)"%s: messages %d, values", label, n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %d", values[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

/* The waiting threads: how many, how many are of type vpiThread, and whether
   they are pairwise different objects. */
static void waiters(vpiHandle obj, const char *label)
{
    vpiHandle it = obj != NULL ? vpi_iterate(vpiWaitingProcesses, obj) : NULL, h;
    vpiHandle list[MAX];
    int n = 0, threads = 0, distinct = 1, i, j;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, h) == vpiThread)
            threads++;
        if (n < MAX)
            list[n] = h;
        n++;
    }
    for (i = 0; i < n && i < MAX; i++)
        for (j = i + 1; j < n && j < MAX; j++)
            if (vpi_compare_objects(list[i], list[j]))
                distinct = 0;
    vpi_printf((PLI_BYTE8 *)"%s: waiting %d, of type vpiThread %d, distinct %d\n", label, n,
               threads, distinct);
}

static PLI_INT32 wait_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_time t;
    vpiHandle full = object_of("mb_full"), empty = object_of("mb_empty"), sem = object_of("sem");

    (void)user_data;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    vpi_printf((PLI_BYTE8 *)"at %d: class objects found %d\n", (int)t.low,
               full != NULL && empty != NULL && sem != NULL);
    messages(full, "mb_full");
    waiters(full, "mb_full");
    messages(empty, "mb_empty");
    waiters(empty, "mb_empty");
    waiters(sem, "sem");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_wait";
    d.calltf = wait_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
