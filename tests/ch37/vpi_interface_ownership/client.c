/* Observe native data and traverse an independently selected set of VPI owners. */
#include <stddef.h>
#include "client.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interface_ownership"

#if defined(vpiInterface) && defined(vpiInterfaceArray) && defined(vpiProgram) && defined(vpiModPath)
static int same(vpiHandle a, vpiHandle b)
{
    return a && b && vpi_compare_objects(a, b);
}

static int typed(vpiHandle object, PLI_INT32 type)
{
    return object && vpi_get(vpiType, object) == type;
}

static vpiHandle named(const char *name, vpiHandle scope)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, scope);
}

static vpiHandle from(PLI_INT32 relation, vpiHandle object)
{
    return object ? vpi_handle(relation, object) : NULL;
}

static vpiHandle one(PLI_INT32 relation, vpiHandle object)
{
    const vpiHandle iterator = object ? vpi_iterate(relation, object) : NULL;
    const vpiHandle item = iterator ? vpi_scan(iterator) : NULL;
    if (item)
        vpi_release_handle(iterator);
    return item;
}

static void show_paths(const char *label, vpiHandle owner, vpiHandle other, vpiHandle top)
{
    int count = 0, type_count = 0, instances = 0, foreign = 0, modules = 0, null_modules = 0, ancestor = 0;
    unsigned endpoints = 0;
    const vpiHandle inputs[2] = {named("a", owner), named("b", owner)};
    const vpiHandle output = named("y", owner);
    const vpiHandle iterator = owner ? vpi_iterate(vpiModPath, owner) : NULL;
    vpiHandle path;
    while (iterator && (path = vpi_scan(iterator))) {
        ++count;
        type_count += typed(path, vpiModPath);
        const vpiHandle src = from(vpiExpr, one(vpiModPathIn, path));
        const vpiHandle dst = from(vpiExpr, one(vpiModPathOut, path));
        if (same(dst, output)) {
            for (unsigned index = 0; index < 2; ++index) {
                if (same(src, inputs[index]))
                    endpoints |= 1U << index;
            }
        }
        const vpiHandle instance = from(vpiInstance, path);
        const vpiHandle module = from(vpiModule, path);
        instances += same(instance, owner);
        foreign += same(instance, other);
        modules += same(module, owner);
        null_modules += module == NULL;
        ancestor += same(module, top);
    }
    vpi_printf((PLI_BYTE8 *)"%s paths=%d typed=%d endpoints=%u owner=%d sibling=%d legacy=%d null=%d ancestor=%d\n",
               label, count, type_count, endpoints, instances, foreign, modules, null_modules, ancestor);
}

static void show_children(const char *label, PLI_INT32 kind, vpiHandle program,
                          vpiHandle match, vpiHandle other, vpiHandle physical)
{
    int count = 0, expected = 0, owner = 0, sibling = 0, controls = 0;
    const vpiHandle iterator = program ? vpi_iterate(kind, program) : NULL;
    vpiHandle object;
    while (iterator && (object = vpi_scan(iterator))) {
        ++count;
        expected += typed(object, kind) && same(object, match);
        owner += same(from(vpiInstance, object), program);
        sibling += same(object, other);
        controls += same(object, physical);
    }
    vpi_printf((PLI_BYTE8 *)"%s %s children=%d match=%d owner=%d sibling=%d physical=%d\n",
               label, kind == vpiInterface ? "scalar" : "array", count, expected, owner, sibling, controls);
}

static int valid_members(vpiHandle array, const vpiHandle before[2])
{
    const vpiHandle first = array ? vpi_handle_by_index(array, 0) : NULL;
    const vpiHandle second = array ? vpi_handle_by_index(array, 1) : NULL;
    return typed(first, vpiInterface) && typed(second, vpiInterface) && !same(first, second)
        && same(first, before[0]) && same(second, before[1]);
}

static void show(const char *phase, const design_handles *d, const vpiHandle members[2][2])
{
    vpi_printf((PLI_BYTE8 *)"phase %s controls module=%d/%d members=%d/%d path-parents=%d/%d\n",
               phase, same(from(vpiInstance, d->physical), d->top),
               same(from(vpiInstance, d->physical_array), d->top),
               valid_members(d->array[0], members[0]), valid_members(d->array[1], members[1]),
               same(from(vpiInstance, d->path[0]), d->top), same(from(vpiInstance, d->path[1]), d->top));
    show_children("left", vpiInterface, d->program[0], d->scalar[0], d->scalar[1], d->physical);
    show_children("right", vpiInterface, d->program[1], d->scalar[1], d->scalar[0], d->physical);
    show_children("left", vpiInterfaceArray, d->program[0], d->array[0], d->array[1], d->physical_array);
    show_children("right", vpiInterfaceArray, d->program[1], d->array[1], d->array[0], d->physical_array);
    show_paths("module", d->timing, d->path[0], d->top);
    show_paths("left", d->path[0], d->path[1], d->top);
    show_paths("right", d->path[1], d->path[0], d->top);
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    const vpiHandle top = named(TOP, NULL);
    const design_handles design = {
        top, named("timing", top), named("physical", top), named("physical_array", top),
        {named("left_path", top), named("right_path", top)},
        {named("left_program", top), named("right_program", top)},
        {named("left_scalar", top), named("right_scalar", top)},
        {named("left_array", top), named("right_array", top)},
    };
    if (!typed(top, vpiModule) || !typed(design.timing, vpiModule)) {
        vpi_printf((PLI_BYTE8 *)"design handles unavailable\n");
        return 0;
    }
    vpiHandle members[2][2] = {{NULL, NULL}, {NULL, NULL}};
    for (int index = 0; index < 2; ++index) {
        if (!typed(design.path[index], vpiInterface) || !typed(design.program[index], vpiProgram)
            || !typed(design.scalar[index], vpiInterface) || !typed(design.array[index], vpiInterfaceArray)) {
            vpi_printf((PLI_BYTE8 *)"owner handles unavailable\n");
            return 0;
        }
        members[index][0] = vpi_handle_by_index(design.array[index], 0);
        members[index][1] = vpi_handle_by_index(design.array[index], 1);
    }
    show("native", &design, members);
#ifdef SEED_INTERFACE_OWNERSHIP
    if (attach_fixture_ownership(&design))
        show("seeded", &design, members);
    else
        vpi_printf((PLI_BYTE8 *)"could not seed ownership\n");
#endif
    return 0;
}
#else
static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf((PLI_BYTE8 *)"ownership VPI declarations unavailable\n");
    return 0;
}
#endif

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_interface_owners";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
