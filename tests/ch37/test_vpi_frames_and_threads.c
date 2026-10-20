/* VPI application of test_vpi_frames_and_threads (IEEE 1800-2023 37.43, 37.44). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_frames_and_threads"

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int frames_ended, threads_ended;

static PLI_INT32 on_end(p_cb_data cb)
{
    if (cb->reason == cbEndOfFrame)
        frames_ended++;
    else if (cb->reason == cbEndOfThread)
        threads_ended++;
    return 0;
}

static void place(PLI_INT32 reason, vpiHandle obj)
{
    static s_vpi_time suppress;
    s_cb_data d;

    memset(&d, 0, sizeof d);
    suppress.type = vpiSuppressTime;
    d.reason = reason;
    d.cb_rtn = on_end;
    d.obj = obj;
    d.time = &suppress;
    if (obj == NULL || vpi_register_cb(&d) == NULL)
        vpi_printf((PLI_BYTE8 *)"callback %d not placed\n", (int)reason);
}

/* Prints the value of the automatic variable want of the frame. */
static void automatic_var(vpiHandle frame, const char *want)
{
    vpiHandle it = frame ? vpi_iterate(vpiAutomatics, frame) : NULL, h;
    int found = 0;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), want) == 0) {
            vpi_printf((PLI_BYTE8 *)" %s=%d", want, int_value(h));
            found = 1;
        }
    if (!found)
        vpi_printf((PLI_BYTE8 *)" no %s", want);
}

static const char *kind(vpiHandle h)
{
    if (h == NULL)
        return "none";
    switch (vpi_get(vpiType, h)) {
    case vpiSysTaskCall: return "system task call";
    case vpiTaskCall: return "task call";
    default: return "other";
    }
}

static PLI_INT32 frame_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle f = vpi_handle(vpiFrame, NULL), parent;

    (void)user_data;
    if (f == NULL) {
        vpi_printf((PLI_BYTE8 *)"no active frame\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"inner frame:");
    automatic_var(f, "doubled");
    vpi_printf((PLI_BYTE8 *)", active %d\n", (int)vpi_get(vpiActive, f));
    vpi_printf((PLI_BYTE8 *)"current statement: %s, origin: %s\n", kind(vpi_handle(vpiStmt, f)),
               kind(vpi_handle(vpiOrigin, f)));
    parent = vpi_handle(vpiParent, f);
    vpi_printf((PLI_BYTE8 *)"parent frame:");
    automatic_var(parent, "next");
    vpi_printf((PLI_BYTE8 *)", its statement: %s\n",
               kind(parent ? vpi_handle(vpiStmt, parent) : NULL));
    place(cbEndOfFrame, f);
    place(cbEndOfThread, vpi_handle(vpiThread, f));
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"frames ended: %d, threads ended: %d\n", frames_ended, threads_ended);
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
    add("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
