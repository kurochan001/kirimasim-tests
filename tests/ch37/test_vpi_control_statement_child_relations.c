#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int has(vpiHandle object, int relation)
{ return object != NULL && vpi_handle(relation, object) != NULL; }
static int count(vpiHandle object, int relation)
{
    vpiHandle it = object ? vpi_iterate(relation, object) : NULL, h;
    int n = 0; while (it && (h = vpi_scan(it)) != NULL) n++;
    return n;
}
static int value_of(vpiHandle h)
{
    s_vpi_value v;
    if (!h) return -1000;
    v.format = vpiIntVal; vpi_get_value(h, &v); return v.value.integer;
}
static PLI_INT32 children(PLI_BYTE8 *data)
{
    static const char *names[] = {"assert", "assume", "cover", "event", "while", "repeat",
        "wait", "forever", "if_else", "expect", "for", "disable", "return", "repeat_control"};
    int ok[14] = {0}, n = 0, k;
    vpiHandle task, body, it, h, repeat_control, target;
    (void)data;
    task = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_control_statement_child_relations.inspected", NULL);
    body = task ? vpi_handle(vpiStmt, task) : NULL;
    it = body ? vpi_iterate(vpiStmt, body) : NULL;
    while (it && (h = vpi_scan(it)) != NULL) {
        n++;
        switch (vpi_get(vpiType, h)) {
        case vpiImmediateAssert:
            ok[0] = has(h, vpiExpr) && has(h, vpiStmt) && has(h, vpiElseStmt); break;
        case vpiImmediateAssume:
            ok[1] = has(h, vpiExpr) && has(h, vpiStmt) && has(h, vpiElseStmt); break;
        case vpiImmediateCover: ok[2] = has(h, vpiExpr) && has(h, vpiStmt); break;
        case vpiEventStmt: ok[3] = has(h, vpiNamedEvent) && vpi_get(vpiBlocking, h); break;
        case vpiWhile: ok[4] = has(h, vpiCondition) && has(h, vpiStmt); break;
        case vpiRepeat:
            ok[5] = value_of(vpi_handle(vpiCondition, h)) == 3 && has(h, vpiStmt); break;
        case vpiWait: ok[6] = has(h, vpiCondition) && has(h, vpiStmt); break;
        case vpiForever: ok[7] = has(h, vpiStmt); break;
        case vpiIfElse:
            ok[8] = has(h, vpiCondition) && has(h, vpiStmt) && has(h, vpiElseStmt); break;
        case vpiExpectStmt:
            ok[9] = has(h, vpiProperty) && has(h, vpiStmt) && has(h, vpiElseStmt); break;
        case vpiFor:
            ok[10] = has(h, vpiCondition) && has(h, vpiStmt)
                && count(h, vpiForInitStmt) == 1 && count(h, vpiForIncStmt) == 1; break;
        case vpiDisable:
            target = vpi_handle(vpiExpr, h);
            ok[11] = target && task && vpi_compare_objects(target, task); break;
        case vpiReturnStmt: ok[12] = vpi_handle(vpiCondition, h) == NULL; break;
        case vpiAssignment:
            repeat_control = vpi_handle(vpiRepeatControl, h);
            ok[13] = repeat_control && value_of(vpi_handle(vpiExpr, repeat_control)) == 2
                && has(repeat_control, vpiEventControl); break;
        default: break;
        }
    }
    for (k = 0; k < 14; k++) vpi_printf("%s=%d\n", names[k], ok[k]);
    vpi_printf("objects=%d\n", n);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data tf;
    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask; tf.tfname = (PLI_BYTE8 *)"$depth_children"; tf.calltf = children;
    vpi_register_systf(&tf);

}
void (*vlog_startup_routines[])(void) = {register_all, 0};
#ifdef __cplusplus
}
#endif
