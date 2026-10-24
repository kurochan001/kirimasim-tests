/* VPI application of test_vpi_thread_parent_children_frame (IEEE 1800-2023 37.44, 37.43). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 8
#define LEN 32

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

/* The names of the automatic variables of a frame, joined by spaces. */
static void automatics(vpiHandle frame, char *out, size_t size)
{
    vpiHandle it = frame != NULL ? vpi_iterate(vpiAutomatics, frame) : NULL, h;
    const char *s;

    out[0] = '\0';
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        s = vpi_get_str(vpiName, h);
        if (out[0] != '\0')
            strncat(out, " ", size - strlen(out) - 1);
        strncat(out, s != NULL ? s : "(none)", size - strlen(out) - 1);
    }
    if (out[0] == '\0')
        snprintf(out, size, "(none)");
}

/* At 0, in deep. */
static PLI_INT32 in_deep_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle frame = vpi_handle(vpiFrame, NULL);
    vpiHandle caller = frame != NULL ? vpi_handle(vpiParent, frame) : NULL;
    vpiHandle thread = frame != NULL ? vpi_handle(vpiThread, frame) : NULL;
    vpiHandle of_thread = thread != NULL ? vpi_handle(vpiFrame, thread) : NULL;

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"at 0: frame of the current thread is the active frame %d, "
                            "is the caller's frame %d\n", same(of_thread, frame),
               same(of_thread, caller));
    return 0;
}

/* At 1, in probe, called by parent_proc. */
static PLI_INT32 children_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle frame = vpi_handle(vpiFrame, NULL);
    vpiHandle me = frame != NULL ? vpi_handle(vpiThread, frame) : NULL;
    vpiHandle it = me != NULL ? vpi_iterate(vpiThread, me) : NULL, child, cf;
    char names[MAX][LEN], caller_of_level[LEN];
    int n = 0, threads = 0, back = 0, frames = 0, i;

    (void)user_data;
    snprintf(caller_of_level, sizeof caller_of_level, "(none)");
    while (it != NULL && (child = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, child) == vpiThread)
            threads++;
        back += same(vpi_handle(vpiParent, child), me);
        cf = vpi_handle(vpiFrame, child);
        if (cf != NULL && frames < MAX) {
            automatics(cf, names[frames], LEN);
            if (strcmp(names[frames], "level") == 0)
                automatics(vpi_handle(vpiParent, cf), caller_of_level, sizeof caller_of_level);
            frames++;
        }
        n++;
    }
    qsort(names, (size_t)frames, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"at 1: children of the current thread %d, of type vpiThread %d, "
                            "leading back with vpiParent %d\n", n, threads, back);
    vpi_printf((PLI_BYTE8 *)"automatic variables of the frames of the children:");
    for (i = 0; i < frames; i++)
        vpi_printf((PLI_BYTE8 *)" [%s]", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
    vpi_printf((PLI_BYTE8 *)"caller of the frame with level: [%s]\n", caller_of_level);
    return 0;
}

/* At 10, in probe_all, called by parent_proc. */
static PLI_INT32 all_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle frame = vpi_handle(vpiFrame, NULL);
    vpiHandle me = frame != NULL ? vpi_handle(vpiThread, frame) : NULL;
    vpiHandle it = vpi_iterate(vpiThread, NULL), h;
    int n = 0, threads = 0, mine = 0;

    (void)user_data;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, h) == vpiThread)
            threads++;
        mine += same(h, me);
        n++;
    }
    vpi_printf((PLI_BYTE8 *)"at 10: threads from NULL %d, of type vpiThread %d, "
                            "the current thread among them %d\n", n, threads, mine);
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
    add("$vt_in_deep", in_deep_calltf);
    add("$vt_children", children_calltf);
    add("$vt_all", all_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
