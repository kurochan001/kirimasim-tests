/* VPI application of test_vpi_system_call_decompile (IEEE 1800-2023 37.42). */
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_system_call_decompile"
#define MAX 8

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static int by_text(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}

/* Copies s without white space into out. */
static void squeeze(const char *s, char *out, size_t len)
{
    size_t n = 0;

    while (s != NULL && *s != '\0' && n + 1 < len) {
        if (!isspace((unsigned char)*s))
            out[n++] = *s;
        s++;
    }
    out[n] = '\0';
}

static PLI_INT32 calls_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle task = NULL, body, it, s;
    const char *lines[MAX];
    char storage[MAX][128];
    int n = 0, i, j;

    (void)user_data;
    task = NULL;
    {
        vpiHandle tit = top != NULL ? vpi_iterate(vpiTaskFunc, top) : NULL, t;

        while (tit != NULL && (t = vpi_scan(tit)) != NULL)
            if (strcmp(sprop(vpiName, t), "calls") == 0) {
                task = t;
                break;
            }
    }
    body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL;
    while (it != NULL && (s = vpi_scan(it)) != NULL && n < MAX) {
        vpiHandle call = s;
        char squeezed[96];

        if (vpi_get(vpiType, s) == vpiAssignment)
            call = vpi_handle(vpiRhs, s);
        if (call == NULL)
            continue;
        if (vpi_get(vpiType, call) != vpiSysFuncCall
            && vpi_get(vpiType, call) != vpiSysTaskCall)
            continue;
        squeeze(sprop(vpiDecompile, call), squeezed, sizeof squeezed);
        snprintf(storage[n], sizeof storage[0], "%s: name %s, user %d, decompile '%s'",
                 squeezed, sprop(vpiName, call), (int)vpi_get(vpiUserDefn, call),
                 squeezed);
        lines[n] = storage[n];
        n++;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (by_text(&lines[i], &lines[j]) > 0) {
                const char *t = lines[i];
                lines[i] = lines[j];
                lines[j] = t;
            }
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    return 0;
}

static PLI_INT32 calls_report(PLI_BYTE8 *user_data)
{
    (void)user_data;
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
    add("$vt_calls", calls_calltf);
    add("$vt_marked", calls_report);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
