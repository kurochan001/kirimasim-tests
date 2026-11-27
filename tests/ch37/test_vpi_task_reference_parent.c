#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* The SystemVerilog type code may be absent from older compatibility headers. */
#ifndef vpiRefObj
#define vpiRefObj 608
#endif

#ifdef SEED_REFERENCE_PARENT
vpiHandle make_reference_view(vpiHandle declaration, vpiHandle target);
#endif

static vpiHandle related(PLI_INT32 relation, vpiHandle owner)
{
    return owner ? vpi_handle(relation, owner) : NULL;
}

static PLI_INT32 kind(vpiHandle object)
{
    return object ? vpi_get(vpiType, object) : 0;
}

static int same(vpiHandle first, vpiHandle second)
{
    return first && second && vpi_compare_objects(first, second);
}

static int named(vpiHandle object, const char *name)
{
    const char *actual = object ? vpi_get_str(vpiName, object) : NULL;
    return actual && strcmp(actual, name) == 0;
}

static vpiHandle formal_expr(vpiHandle declaration, const char *name)
{
    vpiHandle it = declaration ? vpi_iterate(vpiIODecl, declaration) : NULL;
    vpiHandle formal = it ? vpi_scan(it) : NULL;
    if (!formal) return NULL;
    if (vpi_scan(it)) {
        vpi_release_handle(it);
        return NULL;
    }
    return named(formal, name) ? related(vpiExpr, formal) : NULL;
}

static PLI_INT32 inspect_references(PLI_BYTE8 *unused)
{
    (void)unused;
    const char *const label[] = {"task", "function", "input-control"};
    const char *const path[] = {
        "test_vpi_task_reference_parent.adjust",
        "test_vpi_task_reference_parent.inspect",
        "test_vpi_task_reference_parent.plain",
    };
    const PLI_INT32 expected_kind[] = {vpiTask, vpiFunction, vpiFunction};
    vpiHandle root = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_task_reference_parent", NULL);
    vpiHandle declarations[3], expressions[3];

    for (int i = 0; i < 3; ++i) {
        declarations[i] = vpi_handle_by_name((PLI_BYTE8 *)path[i], NULL);
        expressions[i] = formal_expr(declarations[i], "bound");
        vpiHandle parent = related(vpiParent, declarations[i]);
        printf("declaration %s kind=%d ref=%d backlink=%d module-parent=%d\n",
               label[i], kind(declarations[i]) == expected_kind[i],
               kind(expressions[i]) == vpiRefObj,
               same(related(vpiTaskFunc, expressions[i]), declarations[i]),
               kind(parent) == vpiModule && same(parent, root));
    }
    printf("reference objects distinct=%d\n",
           expressions[0] && expressions[1] && !same(expressions[0], expressions[1]));

#ifdef SEED_REFERENCE_PARENT
    for (int i = 0; i < 2; ++i) {
        vpiHandle intended = expressions[i], sibling = expressions[1 - i];
#ifndef SWAP_REFERENCE_PARENTS
        vpiHandle view = make_reference_view(declarations[i], intended);
#else
        vpiHandle view = make_reference_view(declarations[i], sibling);
#endif
        vpiHandle parent = related(vpiParent, view);
        printf("view %s kind=%d ref=%d intended=%d sibling=%d backlink=%d\n",
               label[i], kind(view) == expected_kind[i], kind(parent) == vpiRefObj,
               same(parent, intended), same(parent, sibling),
               same(related(vpiTaskFunc, parent), declarations[i]));
    }
#endif
    return 0;
}

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_tf_reference";
    task.calltf = inspect_references;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
