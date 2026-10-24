/* VPI application of test_vpi_tf_call_kinds_relations (IEEE 1800-2023 37.42). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_tf_call_kinds_relations"
#define LEN 128
#define MAX 4

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

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiFuncCall: return "function call";
    case vpiTaskCall: return "task call";
    case vpiMethodFuncCall: return "method function call";
    case vpiMethodTaskCall: return "method task call";
    default: return "other object";
    }
}

static const char *func_type(vpiHandle h)
{
    switch (vpi_get(vpiFuncType, h)) {
    case vpiIntFunc: return "vpiIntFunc";
    case vpiRealFunc: return "vpiRealFunc";
    case vpiTimeFunc: return "vpiTimeFunc";
    case vpiSizedFunc: return "vpiSizedFunc";
    case vpiSizedSignedFunc: return "vpiSizedSignedFunc";
    default: return "other";
    }
}

/* The arguments: constants by value, others by name. */
static void args_text(vpiHandle call, char *out, size_t len)
{
    vpiHandle it = vpi_iterate(vpiArgument, call), a;
    out[0] = '\0';
    while (it != NULL && (a = vpi_scan(it)) != NULL) {
        if (vpi_get(vpiType, a) == vpiConstant)
            snprintf(out + strlen(out), len - strlen(out), " %d", int_value(a));
        else
            snprintf(out + strlen(out), len - strlen(out), " %s", name_of(a));
    }
    if (out[0] == '\0')
        snprintf(out, len, " none");
}

/* What vpiWith gives: NULL, an operation with its operator, or a constraint. */
static const char *with_text(vpiHandle call)
{
    vpiHandle w = vpi_handle(vpiWith, call);
    if (w == NULL)
        return "NULL";
    if (vpi_get(vpiType, w) == vpiConstraint)
        return "a constraint";
    if (vpi_get(vpiType, w) == vpiOperation)
        return vpi_get(vpiOpType, w) == vpiGtOp ? "the operation >" : "another operation";
    return "other object";
}

static void common_text(vpiHandle call, const char *label, char *out, size_t len)
{
    char args[64];
    args_text(call, args, sizeof args);
    snprintf(out, len, "%s: %s, scope %s, arguments:%s\n", label, kind(call),
             name_of(vpi_handle(vpiScope, call)), args);
}

static void method_text(vpiHandle call, const char *label, PLI_INT32 decl_type, char *out,
                        size_t len)
{
    char decl[32];

    /* vpi_get_str can reuse its buffer, so the first name is copied. */
    snprintf(decl, sizeof decl, "%s", name_of(vpi_handle(decl_type, call)));
    snprintf(out, len, "  %s: %s %s, prefix %s, user-defined %d, with %s\n", label,
             decl_type == vpiFunction ? "function" : "task", decl,
             name_of(vpi_handle(vpiPrefix, call)), (int)vpi_get(vpiUserDefn, call),
             with_text(call));
}

static void common(vpiHandle call, const char *label)
{
    char text[LEN];
    common_text(call, label, text, sizeof text);
    vpi_printf((PLI_BYTE8 *)"%s", text);
}

static void method_detail(vpiHandle call, const char *label, PLI_INT32 decl_type)
{
    char text[LEN];
    method_text(call, label, decl_type, text, sizeof text);
    vpi_printf((PLI_BYTE8 *)"%s", text);
}

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static PLI_INT32 args_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL), it, a, blk, st;
    vpiHandle args[6];
    char calls[MAX][2 * LEN];
    int n = 0, n_calls = 0, i;

    (void)user_data;
    it = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    while (it != NULL && (a = vpi_scan(it)) != NULL)
        if (n < 6)
            args[n++] = a;
    if (n != 6) {
        vpi_printf((PLI_BYTE8 *)"arguments: %d\n", n);
        return 0;
    }
    common(args[0], "twice(4)");
    vpi_printf((PLI_BYTE8 *)"  twice(4): function %s, type %s, value %d\n",
               name_of(vpi_handle(vpiFunction, args[0])), func_type(args[0]), int_value(args[0]));
    common(args[1], "half(3.0)");
    vpi_printf((PLI_BYTE8 *)"  half(3.0): function %s, type %s\n",
               name_of(vpi_handle(vpiFunction, args[1])), func_type(args[1]));
    common(args[2], "p.get()");
    method_detail(args[2], "p.get()", vpiFunction);
    vpi_printf((PLI_BYTE8 *)"  p.get(): value %d\n", int_value(args[2]));
    common(args[3], "q.size()");
    method_detail(args[3], "q.size()", vpiFunction);
    vpi_printf((PLI_BYTE8 *)"  q.size(): value %d\n", int_value(args[3]));
    common(args[4], "q.find with");
    method_detail(args[4], "q.find with", vpiFunction);
    common(args[5], "p.randomize() with");
    method_detail(args[5], "p.randomize() with", vpiFunction);

    /* The task call statements of blk, printed sorted by their label. */
    blk = vpi_handle_by_name((PLI_BYTE8 *)TOP ".blk", NULL);
    it = blk != NULL ? vpi_iterate(vpiStmt, blk) : NULL;
    while (it != NULL && (st = vpi_scan(it)) != NULL && n_calls < MAX) {
        if (vpi_get(vpiType, st) == vpiTaskCall) {
            common_text(st, "note(7)", calls[n_calls], LEN);
            snprintf(calls[n_calls] + strlen(calls[n_calls]), 2 * LEN - strlen(calls[n_calls]),
                     "  note(7): task %s\n", name_of(vpi_handle(vpiTask, st)));
            n_calls++;
        } else if (vpi_get(vpiType, st) == vpiMethodTaskCall) {
            const char *label = strcmp(name_of(vpi_handle(vpiPrefix, st)), "p") == 0
                                ? "p.bump()" : "mb.put(1)";
            common_text(st, label, calls[n_calls], LEN);
            method_text(st, label, vpiTask, calls[n_calls] + strlen(calls[n_calls]), LEN);
            n_calls++;
        }
    }
    qsort(calls, (size_t)n_calls, sizeof calls[0], by_text);
    for (i = 0; i < n_calls; i++)
        vpi_printf((PLI_BYTE8 *)"%s", calls[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_args";
    d.calltf = args_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
