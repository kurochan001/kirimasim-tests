/* VPI application of test_vpi_untagged_relation_access (IEEE 1800-2023 37.3, 37.4.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_untagged_relation_access"
#define MAX 8
#define LEN 64

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static vpiHandle find(const char *name)
{
    char full[160];
    vpiHandle h;
    if (name[0] != '\0')
        snprintf(full, sizeof full, "%s.%s", TOP, name);
    else
        snprintf(full, sizeof full, "%s", TOP);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", full);
    return h;
}

/* A double arrow: vpi_iterate, then vpi_scan until NULL; prints the names
   of the objects, sorted. */
static void many(const char *rel, PLI_INT32 type, const char *from, vpiHandle ref)
{
    char names[MAX][LEN];
    vpiHandle it, h;
    int n = 0, i;

    if (ref == NULL)
        return;
    it = vpi_iterate(type, ref);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (n < MAX)
            snprintf(names[n++], LEN, "%s", s ? s : "(null)");
    }
    qsort(names, n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"%s from %s (%d):", rel, from, n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

/* A single arrow: vpi_handle; prints the full name of the object. */
static void one(const char *rel, PLI_INT32 type, const char *from)
{
    vpiHandle ref = find(from), h;
    PLI_BYTE8 *s;

    if (ref == NULL)
        return;
    h = vpi_handle(type, ref);
    s = h != NULL ? vpi_get_str(vpiFullName, h) : NULL;
    vpi_printf((PLI_BYTE8 *)"%s of %s: %s\n", rel, from, s ? s : "(none)");
}

static PLI_INT32 walk_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    many("vpiModule", vpiModule, "the top", find(""));
    many("vpiNet", vpiNet, "the top", find(""));
    many("vpiNet", vpiNet, "u1", find("u1"));
    many("vpiNamedEvent", vpiNamedEvent, "the top", find(""));
    many("vpiNamedEvent", vpiNamedEvent, "u2", find("u2"));
    one("vpiModule", vpiModule, "mid");
    one("vpiModule", vpiModule, "u1.inv");
    one("vpiModule", vpiModule, "u2.a");
    one("vpiModule", vpiModule, "stop");
    one("vpiModule", vpiModule, "u2.done");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_walk";
    d.calltf = walk_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
