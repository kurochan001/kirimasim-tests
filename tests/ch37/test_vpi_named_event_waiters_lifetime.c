/* VPI application of test_vpi_named_event_waiters_lifetime (IEEE 1800-2023 37.27, 37.31). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_named_event_waiters_lifetime"
#define MAX 8

struct item {
    char *name;
    vpiHandle h;
};

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static int collect(PLI_INT32 rel, vpiHandle ref, struct item *list)
{
    vpiHandle it = ref ? vpi_iterate(rel, ref) : NULL, h;
    int n = 0;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = copy(vpi_get_str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    return n;
}

static const char *scheme(vpiHandle h)
{
    switch (vpi_get(vpiAllocScheme, h)) {
    case vpiAutomaticScheme: return "automatic";
    case vpiDynamicScheme: return "dynamic";
    case vpiOtherScheme: return "other";
    default: return "undefined";
    }
}

/* The threads waiting on ev: how many, how many are threads, how many have no
   parent thread, and how many have the thread waiting on ev2 as parent. */
static void waiters(const char *when, vpiHandle ev, vpiHandle ev2)
{
    vpiHandle it = vpi_iterate(vpiWaitingProcesses, ev), t, p;
    vpiHandle it2 = vpi_iterate(vpiWaitingProcesses, ev2);
    vpiHandle parent_thread = it2 ? vpi_scan(it2) : NULL;
    int n = 0, threads = 0, no_parent = 0, child = 0;

    if (parent_thread != NULL && vpi_scan(it2) != NULL)
        parent_thread = NULL; /* exactly one waiter on ev2 is expected */
    while (it != NULL && (t = vpi_scan(it)) != NULL) {
        n++;
        if (vpi_get(vpiType, t) == vpiThread)
            threads++;
        p = vpi_handle(vpiParent, t);
        if (p == NULL)
            no_parent++;
        else if (same(p, parent_thread))
            child++;
    }
    vpi_printf("%s: waiting on ev %d, threads %d, without parent thread %d, "
               "child of the thread waiting on ev2 %d\n", when, n, threads, no_parent, child);
}

static void events(const char *label, PLI_INT32 rel, vpiHandle ref, vpiHandle defn, int from_obj)
{
    struct item list[MAX];
    int n = collect(rel, ref, list), i;
    vpi_printf("%s:", label);
    for (i = 0; i < n; i++) {
        vpi_printf(" %s (automatic %d", list[i].name, (int)vpi_get(vpiAutomatic, list[i].h));
        if (from_obj)
            vpi_printf(", alloc scheme %s", scheme(list[i].h));
        else
            vpi_printf(", class defn is evc %d", same(vpi_handle(vpiClassDefn, list[i].h), defn));
        vpi_printf(")");
    }
    vpi_printf("\n");
}

static PLI_INT32 waiters_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle ev = vpi_handle_by_name((PLI_BYTE8 *)TOP ".ev", NULL);
    vpiHandle ev2 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".ev2", NULL);
    vpiHandle obj = vpi_handle_by_name((PLI_BYTE8 *)TOP ".obj", NULL);
    vpiHandle defn, cobj;
    struct item list[MAX];
    int n, i;

    (void)user_data;
    if (top == NULL || ev == NULL || ev2 == NULL || obj == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    waiters("at 1", ev, ev2);
    vpi_printf("ev: automatic %d, alloc scheme %s\n", (int)vpi_get(vpiAutomatic, ev), scheme(ev));

    n = collect(vpiClassDefn, top, list);
    defn = NULL;
    for (i = 0; i < n; i++)
        if (strcmp(list[i].name, "evc") == 0)
            defn = list[i].h;
    vpi_printf("class defn evc: %s\n", defn ? "found" : "NULL");
    events("named events of evc", vpiNamedEvent, defn, defn, 0);
    events("named event arrays of evc", vpiNamedEventArray, defn, defn, 0);

    cobj = vpi_handle(vpiClassObj, obj);
    vpi_printf("class obj of obj: %s\n", cobj ? "found" : "NULL");
    events("named events of the object", vpiNamedEvent, cobj, defn, 1);
    events("named event arrays of the object", vpiNamedEventArray, cobj, defn, 1);

    vpi_put_value(ev, NULL, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 after_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    waiters("at 2", vpi_handle_by_name((PLI_BYTE8 *)TOP ".ev", NULL),
            vpi_handle_by_name((PLI_BYTE8 *)TOP ".ev2", NULL));
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
    add("$vt_waiters", waiters_calltf);
    add("$vt_after", after_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
