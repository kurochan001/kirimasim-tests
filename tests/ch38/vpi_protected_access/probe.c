#include <stdio.h>
#include <string.h>
#include "adapter.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_protected_access_controls"

static const char *error_for(const char *operation)
{
    s_vpi_error_info info = {0};
    PLI_INT32 level = access_error(&info);
    if (level == 0)
        return "ok";
    if (level == vpiError && info.code != NULL && strcmp(info.code, "protected_object") == 0 &&
        info.message != NULL && strcmp(info.message, operation) == 0)
        return "denied";
    return "unexpected";
}

static void properties(const char *label, vpiHandle object)
{
    PLI_INT32 flag = access_get(vpiIsProtected, object);
    const char *flag_error = error_for("vpi_get");
    PLI_INT32 kind = access_get(vpiType, object);
    const char *kind_error = error_for("vpi_get");
    vpi_printf("%s handle=%d flag=%d/%s type=%d/%s\n", label, object != NULL, (int)flag, flag_error,
               object != NULL && kind > 0 && kind == vpi_get(vpiType, object), kind_error);
}

static void grid(const char *label, vpiHandle object)
{
    properties(label, object);
    PLI_INT32 size = access_get(vpiSize, object);
    vpi_printf("%s get=%d/%s\n", label, (int)size, error_for("vpi_get"));
    const char *name = access_get_str(vpiName, object);
    char copied[96];
    snprintf(copied, sizeof copied, "%s", name != NULL ? name : "NULL");
    vpi_printf("%s string=%s/%s\n", label, copied, error_for("vpi_get_str"));

    vpiHandle parent = access_handle(vpiScope, object);
    vpi_printf("%s parent=%d/%s\n", label, parent != NULL, error_for("vpi_handle"));
    vpiHandle slice = access_index(object, -1);
    vpi_printf("%s index=%d/%s\n", label, slice != NULL, error_for("vpi_handle_by_index"));
    PLI_INT32 indices[] = {-1, 5};
    vpiHandle item = access_multi_index(object, 2, indices);
    const char *error = error_for("vpi_handle_by_multi_index");
    s_vpi_value data = {0};
    if (item != NULL) {
        data.format = vpiIntVal;
        vpi_get_value(item, &data);
    }
    vpi_printf("%s multi=%d/%s value=%d\n", label, item != NULL, error, (int)data.value.integer);
}

static void class_variable(const char *label, vpiHandle object)
{
    properties(label, object);
#ifdef vpiObjId
    PLI_INT64 identity = access_get64(vpiObjId, object);
    vpi_printf("%s get64=%s/%s\n", label, identity > 0 ? "positive" : (identity == -1 ? "-1" : "other"),
               error_for("vpi_get64"));
#else
    vpi_printf("%s get64=unavailable\n", label);
#endif
}

static void scope(const char *label, const char *path, vpiHandle object)
{
    properties(label, object);
    vpiHandle scoped = access_name((PLI_BYTE8 *)"sample", object);
    vpi_printf("%s scoped-name=%d/%s\n", label, scoped != NULL, error_for("vpi_handle_by_name"));
    char full[192];
    snprintf(full, sizeof full, "%s.sample", path);
    vpiHandle hierarchical = access_name((PLI_BYTE8 *)full, NULL);
    vpi_printf("%s full-name=%d/%s\n", label, hierarchical != NULL, error_for("vpi_handle_by_name"));
    vpiHandle iterator = access_iterate(vpiNet, object);
    const char *error = error_for("vpi_iterate");
    int nets = 0;
    while (iterator != NULL && access_scan(iterator) != NULL)
        ++nets;
    vpi_printf("%s iterate=%d/%s\n", label, nets, error);
}

static PLI_INT32 arguments(PLI_BYTE8 *user_data)
{
    static int sequence;
    ++sequence;
    char label[24];
    snprintf(label, sizeof label, "call%d", sequence);
    vpiHandle call = access_handle(vpiSysTfCall, NULL);
    properties(label, call);
    PLI_INT32 kind = access_get(vpiType, call);
    vpi_printf("%s kind=%s/%s\n", label, kind == vpiSysTaskCall ? "task" :
               kind == vpiSysFuncCall ? "function" : "other", error_for("vpi_get"));
    vpiHandle iterator = access_iterate(vpiArgument, call);
    vpi_printf("%s arguments=%d/%s\n", label, iterator != NULL, error_for("vpi_iterate"));
    unsigned index = 0;
    vpiHandle item;
    while (iterator != NULL && (item = access_scan(iterator)) != NULL) {
        snprintf(label, sizeof label, "call%d.arg%u", sequence, ++index);
        properties(label, item);
        PLI_INT32 width = access_get(vpiSize, item);
        vpi_printf("%s expression-size=%d/%s\n", label, (int)width, error_for("vpi_get"));
    }
    if (user_data != NULL) {
        s_vpi_value result = {0};
        result.format = vpiIntVal;
        result.value.integer = 17;
        vpi_put_value(call, &result, NULL, vpiNoDelay);
    }
    return 0;
}

static PLI_INT32 at_end(p_cb_data unused)
{
    (void)unused;
    vpiHandle top = access_name((PLI_BYTE8 *)TOP, NULL);
    properties("top", top);
    grid("left_grid", access_name((PLI_BYTE8 *)"left_grid", top));
    grid("right_grid", access_name((PLI_BYTE8 *)"right_grid", top));
    class_variable("left_object", access_name((PLI_BYTE8 *)"left_object", top));
    class_variable("right_object", access_name((PLI_BYTE8 *)"right_object", top));
    scope("left_scope", TOP ".left_scope", access_name((PLI_BYTE8 *)TOP ".left_scope", NULL));
    scope("right_scope", TOP ".right_scope", access_name((PLI_BYTE8 *)TOP ".right_scope", NULL));
    return 0;
}

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_protection_arguments";
    task.calltf = arguments;
    vpi_register_systf(&task);
    task.type = vpiSysFunc;
    task.sysfunctype = vpiIntFunc;
    task.tfname = (PLI_BYTE8 *)"$vt_protection_function";
    task.user_data = (PLI_BYTE8 *)"function";
    vpi_register_systf(&task);
    s_cb_data callback = {0};
    callback.reason = cbEndOfSimulation;
    callback.cb_rtn = at_end;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
