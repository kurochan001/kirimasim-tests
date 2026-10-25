/* VPI application of test_vpi_routines_misc_utilities (IEEE 1800-2023 36.11, Table 36-9). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_routines_misc_utilities"

static PLI_INT32 control_result = -1;

static PLI_INT32 at_end(p_cb_data data)
{
    s_vpi_time now;
    (void)data;
    now.type = vpiSimTime;
    vpi_get_time(NULL, &now);
    vpi_printf("end of simulation at %u, vpi_control(vpiFinish, 0) returned %d\n",
               (unsigned)now.low, (int)control_result);
    return 0;
}

static PLI_INT32 at_25(p_cb_data data)
{
    (void)data;
    control_result = vpi_control(vpiFinish, 0);
    return 0;
}

static vpiHandle place(PLI_INT32 reason, PLI_INT32 (*routine)(p_cb_data), p_vpi_time time)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = reason;
    d.cb_rtn = routine;
    d.time = time;
    return vpi_register_cb(&d);
}

static int int_value(vpiHandle obj)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(obj, &v);
    return (int)v.value.integer;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time t25;
    s_vpi_vlog_info info;
    PLI_INT32 got_info;
    vpiHandle r1, r2, s, it, obj, from_iteration = NULL;
    int k, plusarg = 0, same, differ, iterated, released_it, released_r;
    char name[32];

    (void)data;
    memset(&info, 0, sizeof info);
    got_info = vpi_get_vlog_info(&info);
    for (k = 1; k < info.argc; k++)
        if (info.argv != NULL && info.argv[k] != NULL && strcmp(info.argv[k], "+vt_mode=fast") == 0)
            plusarg = 1;
    vpi_printf("vpi_get_vlog_info returned %d: argv[0] given %d, +vt_mode=fast among the options "
               "%d, product and version given %d\n", (int)got_info,
               info.argc >= 1 && info.argv != NULL && info.argv[0] != NULL, plusarg,
               info.product != NULL && info.product[0] != '\0' && info.version != NULL
               && info.version[0] != '\0');

    r1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL);
    r2 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL);
    s = vpi_handle_by_name((PLI_BYTE8 *)TOP ".s", NULL);
    it = vpi_iterate(vpiReg, vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL));
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        const char *n = vpi_get_str(vpiName, obj);
        if (n != NULL && strcmp(n, "r") == 0)
            from_iteration = obj;
    }
    same = r1 != NULL && r2 != NULL && vpi_compare_objects(r1, r2);
    differ = r1 != NULL && s != NULL && vpi_compare_objects(r1, s);
    iterated = r1 != NULL && from_iteration != NULL && vpi_compare_objects(r1, from_iteration);
    vpi_printf("vpi_compare_objects: r and r again %d, r and s %d, r and r from an iteration %d\n",
               same, differ, iterated);

    it = vpi_iterate(vpiReg, vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL));
    released_it = it != NULL && vpi_scan(it) != NULL && vpi_release_handle(it);
    released_r = r2 != NULL && vpi_release_handle(r2);
    r2 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL);
    snprintf(name, sizeof name, "%d", r2 != NULL ? int_value(r2) : -1);
    vpi_printf("vpi_release_handle: of an iterator not scanned to its end %d, of a handle of r "
               "%d; r found again: %s\n", released_it, released_r, name);

    t25.type = vpiSimTime;
    t25.high = 0;
    t25.low = 25;
    place(cbAfterDelay, at_25, &t25);
    place(cbEndOfSimulation, at_end, NULL);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
