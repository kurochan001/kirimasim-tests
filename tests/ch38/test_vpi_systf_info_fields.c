/* VPI application of test_vpi_systf_info_fields (IEEE 1800-2023 38.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "vpi_user.h"

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T. */
#ifdef __cplusplus
template <typename A, typename B> struct vt_same { enum { value = 0 }; };
template <typename A> struct vt_same<A, A> { enum { value = 1 }; };
#define SAME_TYPE(e, T) ((int)vt_same<decltype(e), T>::value)
#else
#define SAME_TYPE(e, T) _Generic((e), T: 1, default: 0)
#endif

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle handles[6];
static const char *expected_names[6] = {
    "$vt_task", "$vt_int", "$vt_real", "$vt_time", "$vt_sized", "$vt_signed"
};
static char task_data[] = "task";

static PLI_INT32 routine_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 0;
}

static PLI_INT32 routine_compiletf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 0;
}

static PLI_INT32 routine_sizetf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 12;
}

static const char *function_type(PLI_INT32 type)
{
    switch (type) {
    case vpiIntFunc: return "vpiIntFunc";
    case vpiRealFunc: return "vpiRealFunc";
    case vpiTimeFunc: return "vpiTimeFunc";
    case vpiSizedFunc: return "vpiSizedFunc";
    case vpiSizedSignedFunc: return "vpiSizedSignedFunc";
    default: return "other";
    }
}

static void layout(void)
{
    int order = offsetof(s_vpi_systf_data, type) < offsetof(s_vpi_systf_data, sysfunctype)
                && offsetof(s_vpi_systf_data, sysfunctype) < offsetof(s_vpi_systf_data, tfname)
                && offsetof(s_vpi_systf_data, tfname) < offsetof(s_vpi_systf_data, calltf)
                && offsetof(s_vpi_systf_data, calltf) < offsetof(s_vpi_systf_data, compiletf)
                && offsetof(s_vpi_systf_data, compiletf) < offsetof(s_vpi_systf_data, sizetf)
                && offsetof(s_vpi_systf_data, sizetf) < offsetof(s_vpi_systf_data, user_data);

    vpi_printf("type PLI_INT32 %d\n", SAME_TYPE(((s_vpi_systf_data *)0)->type, PLI_INT32));
    vpi_printf("sysfunctype PLI_INT32 %d\n",
               SAME_TYPE(((s_vpi_systf_data *)0)->sysfunctype, PLI_INT32));
    vpi_printf("calltf PLI_INT32 (*)(PLI_BYTE8 *) %d\n",
               SAME_TYPE(((s_vpi_systf_data *)0)->calltf, PLI_INT32 (*)(PLI_BYTE8 *)));
    vpi_printf("compiletf PLI_INT32 (*)(PLI_BYTE8 *) %d\n",
               SAME_TYPE(((s_vpi_systf_data *)0)->compiletf, PLI_INT32 (*)(PLI_BYTE8 *)));
    vpi_printf("sizetf PLI_INT32 (*)(PLI_BYTE8 *) %d\n",
               SAME_TYPE(((s_vpi_systf_data *)0)->sizetf, PLI_INT32 (*)(PLI_BYTE8 *)));
    vpi_printf("user_data PLI_BYTE8 * %d\n",
               SAME_TYPE(((s_vpi_systf_data *)0)->user_data, PLI_BYTE8 *));
    vpi_printf("field order type sysfunctype tfname calltf compiletf sizetf user_data %d\n",
               order);
}

static PLI_INT32 on_start(p_cb_data data)
{
    int k;

    (void)data;
    layout();
    for (k = 0; k < 6; k++) {
        s_vpi_systf_data d;
        const char *name;

        memset(&d, 0, sizeof d);
        if (handles[k] != NULL)
            vpi_get_systf_info(handles[k], &d);
        name = d.tfname != NULL ? d.tfname : "(no name)";
        vpi_printf("%s: %s, %s, name starts $ %d, calltf %d, compiletf %d, sizetf %d, "
                   "user data %s\n", expected_names[k],
                   d.type == vpiSysTask ? "task" : "function",
                   d.type == vpiSysTask ? "none" : function_type(d.sysfunctype),
                   name[0] == '$' ? 1 : 0, d.calltf != NULL ? 1 : 0,
                   d.compiletf != NULL ? 1 : 0, d.sizetf != NULL ? 1 : 0,
                   d.user_data != NULL ? (const char *)d.user_data : "(NULL)");
        if (strcmp(name, expected_names[k]) != 0)
            vpi_printf("%s: wrong name\n", expected_names[k]);
    }
    return 0;
}

static vpiHandle add(PLI_INT32 type, PLI_INT32 sysfunctype, const char *name,
                     PLI_INT32 (*compiletf)(PLI_BYTE8 *), PLI_INT32 (*sizetf)(PLI_BYTE8 *),
                     PLI_BYTE8 *user_data)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = type;
    d.sysfunctype = sysfunctype;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = routine_calltf;
    d.compiletf = compiletf;
    d.sizetf = sizetf;
    d.user_data = user_data;
    return vpi_register_systf(&d);
}

static void register_all(void)
{
    s_cb_data cb;

    handles[0] = add(vpiSysTask, 0, "$vt_task", routine_compiletf, NULL,
                     (PLI_BYTE8 *)task_data);
    handles[1] = add(vpiSysFunc, vpiIntFunc, "$vt_int", NULL, NULL, NULL);
    handles[2] = add(vpiSysFunc, vpiRealFunc, "$vt_real", NULL, NULL, NULL);
    handles[3] = add(vpiSysFunc, vpiTimeFunc, "$vt_time", NULL, NULL, NULL);
    handles[4] = add(vpiSysFunc, vpiSizedFunc, "$vt_sized", NULL, routine_sizetf, NULL);
    handles[5] = add(vpiSysFunc, vpiSizedSignedFunc, "$vt_signed", NULL, routine_sizetf,
                     NULL);
    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
