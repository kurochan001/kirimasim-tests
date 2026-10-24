/* VPI application of test_vpi_function_decl_type_range (IEEE 1800-2023 37.41). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_function_decl_type_range"
#define MAX 8
#define LEN 64

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "NULL";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *func_type(PLI_INT32 t)
{
    switch (t) {
    case vpiIntFunc: return "vpiIntFunc";
    case vpiRealFunc: return "vpiRealFunc";
    case vpiTimeFunc: return "vpiTimeFunc";
    case vpiSizedFunc: return "vpiSizedFunc";
    case vpiSizedSignedFunc: return "vpiSizedSignedFunc";
    case vpiOtherFunc: return "vpiOtherFunc";
    default: return "other";
    }
}

static vpiHandle find(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* with: 0 type only, 1 type and signedness, 2 also the range */
static void function(const char *name, int with)
{
    vpiHandle f = find(name), l, r;

    if (f == NULL || vpi_get(vpiType, f) != vpiFunction) {
        vpi_printf((PLI_BYTE8 *)"%s: not a function\n", name);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: type %s", name, func_type(vpi_get(vpiFuncType, f)));
    if (with >= 1)
        vpi_printf((PLI_BYTE8 *)", signed %d", (int)vpi_get(vpiSigned, f));
    if (with >= 2) {
        l = vpi_handle(vpiLeftRange, f);
        r = vpi_handle(vpiRightRange, f);
        if (l == NULL || r == NULL)
            vpi_printf((PLI_BYTE8 *)", range NULL");
        else
            vpi_printf((PLI_BYTE8 *)", range %d:%d", int_value(l), int_value(r));
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static void io_decls(const char *name)
{
    vpiHandle tf = find(name), it, io, back;
    char names[MAX][LEN];
    int n = 0, same = 0, i;

    it = tf != NULL ? vpi_iterate(vpiIODecl, tf) : NULL;
    while (it != NULL && (io = vpi_scan(it)) != NULL) {
        back = vpi_handle(vpiTaskFunc, io);
        if (back != NULL && vpi_compare_objects(back, tf))
            same++;
        if (n < MAX)
            snprintf(names[n], LEN, "%s", name_of(io));
        n++;
    }
    qsort(names, (size_t)(n < MAX ? n : MAX), LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"io decls of %s:", name);
    for (i = 0; i < n && i < MAX; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)", leading back to it %d of %d\n", same, n);
}

static void methods(void)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), cit, cd, mit, m;
    char lines[MAX][LEN], method[32];
    int n = 0, i;

    cit = top != NULL ? vpi_iterate(vpiClassDefn, top) : NULL;
    while (cit != NULL && (cd = vpi_scan(cit)) != NULL) {
        mit = vpi_iterate(vpiMethods, cd);
        while (mit != NULL && (m = vpi_scan(mit)) != NULL) {
            /* vpi_get_str can reuse its buffer, so the name is copied first. */
            snprintf(method, sizeof method, "%s", name_of(m));
            if (n < MAX)
                snprintf(lines[n++], LEN, "method %s: class defn %s", method,
                         name_of(vpi_handle(vpiClassDefn, m)));
        }
    }
    qsort(lines, (size_t)n, LEN, by_text);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
}

static PLI_INT32 funcs_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    function("f_int", 1);
    function("f_real", 0);
    function("f_time", 1);
    function("f_vec", 2);
    function("f_svec", 2);
    function("f_str", 0);
    io_decls("f_int");
    io_decls("t_io");
    methods();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_funcs";
    d.calltf = funcs_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
