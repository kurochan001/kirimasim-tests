/* VPI application of test_vpi_handle_release_independence (IEEE 1800-2023 37.2.2, 37.2.4, 37.3.8). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_handle_release_independence"

static vpiHandle kept_obj;
static long long kept_id;
static int removed_seen, remaining_seen;

static vpiHandle obj_handle(void)
{
    vpiHandle var = vpi_handle_by_name((PLI_BYTE8 *)TOP ".c", NULL);
    return var != NULL ? vpi_handle(vpiClassObj, var) : NULL;
}

static PLI_INT32 removed_cb(p_cb_data cb)
{
    (void)cb;
    removed_seen++;
    return 0;
}

static PLI_INT32 remaining_cb(p_cb_data cb)
{
    (void)cb;
    remaining_seen++;
    return 0;
}

static vpiHandle change_cb(vpiHandle watched, PLI_INT32 (*rtn)(p_cb_data))
{
    s_cb_data d;
    s_vpi_value v;

    memset(&d, 0, sizeof d);
    v.format = vpiIntVal;
    d.reason = cbValueChange;
    d.cb_rtn = rtn;
    d.obj = watched;
    d.value = &v;
    return vpi_register_cb(&d);
}

static PLI_INT32 release_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle first = obj_handle(), second = obj_handle();
    vpiHandle watched, cb1, cb2;

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"two handles to the class object compare equal %d\n",
               first != NULL && second != NULL
               && vpi_compare_objects(first, second));
    if (first != NULL && second != NULL) {
        PLI_INT64 id1 = vpi_get64(vpiObjId, first);
        PLI_INT64 id2 = vpi_get64(vpiObjId, second);

        vpi_printf((PLI_BYTE8 *)"object id: same at both lookups %d, nonzero %d\n",
                   id1 == id2, id1 != 0);
        kept_id = id1;
    }
    kept_obj = first;
    vpi_release_handle(second);
    vpi_printf((PLI_BYTE8 *)"after releasing one handle, the other still gives the object %d\n",
               kept_obj != NULL && vpi_get64(vpiObjId, kept_obj) == kept_id);

    watched = vpi_handle_by_name((PLI_BYTE8 *)TOP ".watched", NULL);
    cb1 = watched != NULL ? change_cb(watched, removed_cb) : NULL;
    if (cb1 != NULL)
        vpi_printf((PLI_BYTE8 *)"vpi_remove_cb returned %d\n",
                   (int)vpi_remove_cb(cb1));
    cb2 = watched != NULL ? change_cb(watched, remaining_cb) : NULL;
    if (cb2 == NULL)
        vpi_printf((PLI_BYTE8 *)"remaining callback not registered\n");
    return 0;
}

static PLI_INT32 result_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle now = obj_handle();

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"changes seen by removed callback %d, by remaining callback %d\n",
               removed_seen, remaining_seen);
    vpi_printf((PLI_BYTE8 *)"object at time 1 and at time 3 the same %d\n",
               kept_obj != NULL && now != NULL
               && vpi_compare_objects(kept_obj, now)
               && vpi_get64(vpiObjId, now) == kept_id);
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
    add("$vt_release", release_calltf);
    add("$vt_result", result_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
