/* VPI application of test_vpi_prefix_has_actual (IEEE 1800-2023 37.61, 37.29). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_prefix_has_actual"

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int now_time(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 prefix_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top ? vpi_iterate(vpiTaskFunc, top) : NULL, task = NULL, h, body, stmts, s;

    (void)user_data;
    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(name_of(h), "peek") == 0)
            task = h;
    body = task ? vpi_handle(vpiStmt, task) : NULL;
    stmts = body ? vpi_iterate(vpiStmt, body) : NULL;
    if (stmts == NULL) {
        vpi_printf((PLI_BYTE8 *)"the statements of peek were not found\n");
        return 0;
    }
    while ((s = vpi_scan(stmts)) != NULL) {
        vpiHandle rhs = vpi_handle(vpiRhs, s);
        vpiHandle prefix = rhs ? vpi_handle(vpiPrefix, rhs) : NULL;
        vpi_printf((PLI_BYTE8 *)"t=%d: prefix %s, has actual %d\n", now_time(), name_of(prefix),
                   rhs ? (int)vpi_get(vpiHasActual, rhs) : -1);
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
    add("$vt_prefix", prefix_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
