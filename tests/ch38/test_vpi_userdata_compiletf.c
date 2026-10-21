/* VPI application of test_vpi_userdata_compiletf (IEEE 1800-2023 38.33, 38.14). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int compiled, puts_failed;
static char first[] = "first", second[] = "second", third[] = "third";

static PLI_INT32 seq_compiletf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    int *counter = (int *)calloc(1, sizeof *counter);

    (void)user_data;
    compiled++;
    if (call == NULL || vpi_put_userdata(call, counter) != 1)
        puts_failed++;
    return 0;
}

static PLI_INT32 seq_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    int *counter = (int *)vpi_get_userdata(call);
    s_vpi_value v;

    (void)user_data;
    v.format = vpiIntVal;
    v.value.integer = counter ? ++*counter : -1;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 mark_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    char *before = (char *)vpi_get_userdata(call);
    char *next = before == NULL ? first : before == first ? second : third;

    (void)user_data;
    vpi_printf("$vt_mark: stored before: %s, ", before ? before : "NULL");
    vpi_printf("vpi_put_userdata returns %d\n", (int)vpi_put_userdata(call, next));
    return 0;
}

static PLI_INT32 peek_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);

    (void)user_data;
    vpi_printf("$vt_peek: vpi_get_userdata returns %s\n",
               vpi_get_userdata(call) == NULL ? "NULL" : "data");
    vpi_printf("$vt_seq compiletf: %d calls, vpi_put_userdata failed %d times\n", compiled,
               puts_failed);
    return 0;
}

static void add(PLI_INT32 type, const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *),
                PLI_INT32 (*compiletf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = type;
    d.sysfunctype = type == vpiSysFunc ? vpiIntFunc : 0;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    d.compiletf = compiletf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add(vpiSysFunc, "$vt_seq", seq_calltf, seq_compiletf);
    add(vpiSysTask, "$vt_mark", mark_calltf, NULL);
    add(vpiSysTask, "$vt_peek", peek_calltf, NULL);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
