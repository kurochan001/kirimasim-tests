/* VPI application of test_vpi_frames_threads_alloc (IEEE 1800-2023 37.43, 37.44, 37.3.7). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_frames_threads_alloc"

static int objects_created, frames_ended;

static int is_named(vpiHandle h, const char *want)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL && strcmp(s, want) == 0;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
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

/* The variable named want among the objects of an iteration of type over ref. */
static vpiHandle find(PLI_INT32 type, vpiHandle ref, const char *want)
{
    vpiHandle it = ref != NULL ? vpi_iterate(type, ref) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (found == NULL && is_named(h, want))
            found = h;
    return found;
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static PLI_INT32 on_callback(p_cb_data cb)
{
    const char *what = cb->user_data;
    if (strcmp(what, "create") == 0)
        objects_created++;
    else if (strcmp(what, "frame") == 0)
        frames_ended++;
    return 0;
}

static void place(PLI_INT32 reason, vpiHandle obj, const char *what)
{
    static s_vpi_time suppress;
    s_cb_data d;

    memset(&d, 0, sizeof d);
    suppress.type = vpiSuppressTime;
    d.reason = reason;
    d.cb_rtn = on_callback;
    d.obj = obj;
    d.time = &suppress;
    d.user_data = (PLI_BYTE8 *)what;
    if (obj == NULL || vpi_register_cb(&d) == NULL)
        vpi_printf((PLI_BYTE8 *)"%s callback not placed\n", what);
}

static PLI_INT32 setup_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle c = vpi_handle_by_name((PLI_BYTE8 *)TOP ".c", NULL);

    (void)user_data;
    place(cbCreateObj, c != NULL ? vpi_handle(vpiClassTypespec, c) : NULL, "create");
    return 0;
}

static PLI_INT32 check_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle f = vpi_handle(vpiFrame, NULL), caller, thread, loc, sv, c, obj, v;

    (void)user_data;
    if (f == NULL) {
        vpi_printf((PLI_BYTE8 *)"no active frame\n");
        return 0;
    }
    caller = vpi_handle(vpiParent, f);
    thread = vpi_handle(vpiThread, f);
    vpi_printf((PLI_BYTE8 *)"frames: current active %d, caller active %d\n",
               (int)vpi_get(vpiActive, f), caller ? (int)vpi_get(vpiActive, caller) : -1);
    vpi_printf((PLI_BYTE8 *)"thread of the caller's frame is the current thread: %d\n",
               same(caller ? vpi_handle(vpiThread, caller) : NULL, thread));

    loc = find(vpiAutomatics, f, "loc");
    if (loc != NULL)
        vpi_printf((PLI_BYTE8 *)"loc from the frame: value %d, automatic %d, alloc scheme %s, "
                   "has actual %d\n", int_value(loc), (int)vpi_get(vpiAutomatic, loc),
                   scheme(loc), (int)vpi_get(vpiHasActual, loc));
    else
        vpi_printf((PLI_BYTE8 *)"loc from the frame: not found\n");
    loc = find(vpiVariables, vpi_handle_by_name((PLI_BYTE8 *)TOP ".inner", NULL), "loc");
    if (loc != NULL)
        vpi_printf((PLI_BYTE8 *)"loc from the task declaration: automatic %d, has actual %d\n",
                   (int)vpi_get(vpiAutomatic, loc), (int)vpi_get(vpiHasActual, loc));
    else
        vpi_printf((PLI_BYTE8 *)"loc from the task declaration: not found\n");
    sv = vpi_handle_by_name((PLI_BYTE8 *)TOP ".sv", NULL);
    if (sv != NULL)
        vpi_printf((PLI_BYTE8 *)"sv: automatic %d, alloc scheme %s, has actual %d\n",
                   (int)vpi_get(vpiAutomatic, sv), scheme(sv), (int)vpi_get(vpiHasActual, sv));
    else
        vpi_printf((PLI_BYTE8 *)"sv: not found\n");
    c = vpi_handle_by_name((PLI_BYTE8 *)TOP ".c", NULL);
    obj = c != NULL ? vpi_handle(vpiClassObj, c) : NULL;
    v = find(vpiVariables, obj, "v");
    if (v != NULL)
        vpi_printf((PLI_BYTE8 *)"v of the object of c: value %d, alloc scheme %s\n",
                   int_value(v), scheme(v));
    else
        vpi_printf((PLI_BYTE8 *)"v of the object of c: not found\n");

    place(cbEndOfObject, f, "frame");
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"objects created: %d, frames ended: %d\n", objects_created,
               frames_ended);
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
    add("$vt_setup", setup_calltf);
    add("$vt_check", check_calltf);
    add("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
