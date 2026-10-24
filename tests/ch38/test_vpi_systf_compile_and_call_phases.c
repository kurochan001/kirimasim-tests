/* VPI application of test_vpi_systf_compile_and_call_phases (IEEE 1800-2023 38.37). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char mark_tag[] = "mark";
static vpiHandle mark_handle;
static int built, compiletf_before, compiletf_after, wrong_user_data, calltf_count;

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 mark_compiletf(PLI_BYTE8 *user_data)
{
    if (user_data != mark_tag)
        wrong_user_data++;
    if (built)
        compiletf_after++;
    else
        compiletf_before++;
    return 0;
}

static PLI_INT32 mark_calltf(PLI_BYTE8 *user_data)
{
    if (user_data != mark_tag)
        wrong_user_data++;
    calltf_count++;
    vpi_printf((PLI_BYTE8 *)"$vt_mark calltf at %d\n", now());
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_systf_data info;

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"vpi_register_systf returned a vpiUserSystf handle: %d\n",
               mark_handle != NULL && vpi_get(vpiType, mark_handle) == vpiUserSystf);
    memset(&info, 0, sizeof info);
    if (mark_handle != NULL)
        vpi_get_systf_info(mark_handle, &info);
    vpi_printf((PLI_BYTE8 *)"its name: %s\n", info.tfname != NULL ? info.tfname : "(none)");
    vpi_printf((PLI_BYTE8 *)"compiletf before the end of compilation: %d, after: %d\n",
               compiletf_before, compiletf_after);
    vpi_printf((PLI_BYTE8 *)"calltf calls: %d, wrong user_data: %d\n", calltf_count,
               wrong_user_data);
    return 0;
}

static PLI_INT32 on_end_of_compile(p_cb_data cb)
{
    (void)cb;
    built = 1;
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    s_cb_data cb;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_mark";
    d.calltf = mark_calltf;
    d.compiletf = mark_compiletf;
    d.sizetf = NULL;
    d.user_data = mark_tag;
    mark_handle = vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_report";
    d.calltf = report_calltf;
    vpi_register_systf(&d);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfCompile;
    cb.cb_rtn = on_end_of_compile;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
