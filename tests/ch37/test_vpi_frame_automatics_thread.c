/* VPI application of test_vpi_frame_automatics_thread (IEEE 1800-2023 37.43, 37.44). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_frame_automatics_thread"
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

static PLI_INT32 frame_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle f = vpi_handle(vpiFrame, NULL), it, h;
    const char *names[MAX];
    vpiHandle handles[MAX];
    char storage[MAX][48];
    int n = 0, i, j;

    (void)user_data;
    if (f == NULL) {
        vpi_printf((PLI_BYTE8 *)"no active frame\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"frame: active %d\n", (int)vpi_get(vpiActive, f));
    it = vpi_iterate(vpiAutomatics, f);
    while (it != NULL && (h = vpi_scan(it)) != NULL && n < MAX) {
        snprintf(storage[n], sizeof storage[0], "%s (%s)", sprop(vpiName, h),
                 sprop(vpiType, h));
        names[n] = storage[n];
        handles[n++] = h;
    }
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (by_text(&names[i], &names[j]) > 0) {
                const char *t = names[i];
                vpiHandle th = handles[i];
                names[i] = names[j];
                handles[i] = handles[j];
                names[j] = t;
                handles[j] = th;
            }
    vpi_printf((PLI_BYTE8 *)"  automatics:");
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s%s", i ? ", " : " ", names[i]);
    vpi_printf((PLI_BYTE8 *)"%s\n", n ? "" : " none");
    for (i = 0; i < n; i++) {
        vpiHandle back = vpi_handle(vpiFrame, handles[i]);
        vpi_printf((PLI_BYTE8 *)"    %s: back to frame %d\n", names[i],
                   back != NULL && vpi_compare_objects(back, f));
    }
    {
        vpiHandle origin = vpi_handle(vpiOrigin, f);
        vpiHandle parent = vpi_handle(vpiParent, f);
        vpiHandle pstmt = parent != NULL ? vpi_handle(vpiStmt, parent) : NULL;

        vpi_printf((PLI_BYTE8 *)"frame origin: %s at line %d, is parent statement %d\n",
                   sprop(vpiType, origin), (int)vpi_get(vpiLineNo, origin),
                   origin != NULL && pstmt != NULL && vpi_compare_objects(origin, pstmt));
    }
    {
        vpiHandle thread = vpi_handle(vpiThread, f);
        vpiHandle origin = thread != NULL ? vpi_handle(vpiOrigin, thread) : NULL;
        vpiHandle call = vpi_handle(vpiSysTfCall, NULL);

        vpi_printf((PLI_BYTE8 *)"thread: active %d\n",
                   thread != NULL ? (int)vpi_get(vpiActive, thread) : -1);
        vpi_printf((PLI_BYTE8 *)"thread origin: %s at line %d, is current call %d\n",
                   sprop(vpiType, origin), (int)vpi_get(vpiLineNo, origin),
                   origin != NULL && call != NULL && vpi_compare_objects(origin, call));
    }
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
    add("$vt_frame", frame_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
