/* VPI application of test_vpi_systf_startup_routines (IEEE 1800-2023 36.9.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int startup_routines;
static int compiled_at;

static PLI_INT32 probe_compiletf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    compiled_at = startup_routines;
    return 0;
}

static PLI_INT32 probe_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("startup routines run: %d\n", startup_routines);
    vpi_printf("compiletf saw: %d\n", compiled_at);
    return 0;
}

static PLI_INT32 registered_calltf(PLI_BYTE8 *user_data)
{
    vpi_printf("registered by %s\n", user_data);
    return 0;
}

static void add_task(const char *name, const char *routine)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = registered_calltf;
    d.user_data = (PLI_BYTE8 *)routine;
    vpi_register_systf(&d);
}

static void first_routine(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_probe";
    d.compiletf = probe_compiletf;
    d.calltf = probe_calltf;
    vpi_register_systf(&d);
    add_task("$vt_one", "routine 0");
    startup_routines++;
}

static void second_routine(void)
{
    add_task("$vt_two", "routine 1");
    startup_routines++;
}

static void third_routine(void)
{
    add_task("$vt_three", "routine 2");
    startup_routines++;
}

void (*vlog_startup_routines[])(void) = {first_routine, second_routine, third_routine, 0};

#ifdef __cplusplus
}
#endif
