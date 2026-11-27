/* Check public VPI access on the declared constraints and selected nested patterns. */
#include <stddef.h>
#include <string.h>
#include "client.h"

#ifdef __cplusplus
extern "C" {
#endif

#if defined(vpiConstraint) && defined(vpiVirtual) && defined(vpiStructPattern)
static int typed(vpiHandle object, PLI_INT32 kind)
{
    return object && vpi_get(vpiType, object) == kind;
}

static vpiHandle first(PLI_INT32 kind, vpiHandle object)
{
    const vpiHandle iterator = object ? vpi_iterate(kind, object) : NULL;
    const vpiHandle item = iterator ? vpi_scan(iterator) : NULL;
    if (item)
        vpi_release_handle(iterator);
    return item;
}

static vpiHandle locate_constraint(const char *class_name, const char *constraint_name)
{
    const vpiHandle classes = vpi_iterate(vpiClassDefn, NULL);
    vpiHandle cls, found = NULL;
    while (classes && (cls = vpi_scan(classes))) {
        const char *name = vpi_get_str(vpiName, cls);
        if (!name || strcmp(name, class_name) != 0)
            continue;
        const vpiHandle constraints = vpi_iterate(vpiConstraint, cls);
        vpiHandle constraint;
        while (constraints && (constraint = vpi_scan(constraints))) {
            name = vpi_get_str(vpiName, constraint);
            if (typed(constraint, vpiConstraint) && name && strcmp(name, constraint_name) == 0)
                found = constraint;
        }
    }
    return found;
}

static void observe_constraint(const char *class_name, const char *constraint_name)
{
    const vpiHandle constraint = locate_constraint(class_name, constraint_name);
    if (!constraint) {
        vpi_printf((PLI_BYTE8 *)"missing constraint %s.%s\n", class_name, constraint_name);
        return;
    }
#ifdef SEED_PATTERN_CONSTRAINT
    if (!set_constraint_virtual(constraint, constraint_name)) {
        vpi_printf((PLI_BYTE8 *)"missing parsed constraint %s\n", constraint_name);
        return;
    }
#endif
    const PLI_INT32 is_virtual = vpi_get(vpiVirtual, constraint);
    vpi_printf((PLI_BYTE8 *)"constraint %s.%s virtual=%d boolean=%d\n",
               class_name, constraint_name, is_virtual, is_virtual == 0 || is_virtual == 1);
}

static const char *name(vpiHandle object)
{
    const char *text = object ? vpi_get_str(vpiName, object) : NULL;
    return text && *text ? text : "(anonymous)";
}

static vpiHandle locate_pattern(void)
{
    const vpiHandle task = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_pattern_constraint_properties.classify", NULL);
    vpiHandle statement = task ? vpi_handle(vpiStmt, task) : NULL;
    if (!typed(statement, vpiCase))
        statement = first(vpiStmt, statement);
    return first(vpiExpr, first(vpiCaseItem, statement));
}

static vpiHandle member_pattern(vpiHandle parent, const char *binding)
{
    const vpiHandle iterator = vpi_iterate(vpiPattern, parent);
    vpiHandle pattern, found = NULL;
    while (iterator && (pattern = vpi_scan(iterator))) {
        const vpiHandle leaf = first(vpiPattern, pattern);
        if (typed(pattern, vpiStructPattern) && typed(leaf, vpiAnyPattern) && strcmp(name(leaf), binding) == 0)
            found = pattern;
    }
    return found;
}

static void observe_pattern(vpiHandle outer, const char *binding)
{
    const vpiHandle pattern = member_pattern(outer, binding);
    if (!pattern) {
        vpi_printf((PLI_BYTE8 *)"missing pattern binding=%s\n", binding);
        return;
    }
#ifdef SEED_PATTERN_CONSTRAINT
    if (!set_pattern_member_name(pattern, binding)) {
        vpi_printf((PLI_BYTE8 *)"missing parsed pattern binding=%s\n", binding);
        return;
    }
#endif
    vpi_printf((PLI_BYTE8 *)"structure binding=%s member=%s\n", binding, name(pattern));
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    observe_constraint("pure_owner", "pending");
    observe_constraint("fixed_control", "permanent");
    const vpiHandle pattern = locate_pattern();
    if (!typed(pattern, vpiStructPattern)) {
        vpi_printf((PLI_BYTE8 *)"missing outer structure pattern\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"structure outer member=%s\n", name(pattern));
    observe_pattern(pattern, "first");
    observe_pattern(pattern, "second");
    return 0;
}
#else
static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf((PLI_BYTE8 *)"constraint and pattern VPI declarations unavailable\n");
    return 0;
}
#endif

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_pattern_constraint";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
