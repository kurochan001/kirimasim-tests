/* Exercise the same public VPI client with source objects and seeded metadata. */
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "client.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_extended_attribute_owners"

#if defined(vpiAttribute) && defined(vpiPathTerm) && defined(vpiTchk)
typedef struct {
    const char *label;
    PLI_INT32 kind;
    owner_pair pair;
} owner_group;

static vpiHandle by_name(const char *name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
}

static int of_type(vpiHandle object, PLI_INT32 type)
{
    return object && vpi_get(vpiType, object) == type;
}

static int same(vpiHandle left, vpiHandle right)
{
    return left && right && vpi_compare_objects(left, right);
}

static int named(vpiHandle object, const char *name)
{
    PLI_BYTE8 *actual = object ? vpi_get_str(vpiName, object) : NULL;
    return actual && strcmp(actual, name) == 0;
}

static vpiHandle first(PLI_INT32 relation, vpiHandle owner)
{
    vpiHandle iterator = owner ? vpi_iterate(relation, owner) : NULL;
    vpiHandle item = iterator ? vpi_scan(iterator) : NULL;
    if (item)
        vpi_release_handle(iterator);
    return item;
}

static owner_pair rows(vpiHandle udp)
{
    owner_pair pair = {NULL, NULL};
    const vpiHandle defn = udp ? vpi_handle(vpiUdpDefn, udp) : NULL;
    vpiHandle iterator = defn ? vpi_iterate(vpiTableEntry, defn) : NULL;
    if (iterator) {
        pair.first = vpi_scan(iterator);
        if (pair.first)
            pair.second = vpi_scan(iterator);
        if (pair.second)
            vpi_release_handle(iterator);
    }
    return pair;
}

static owner_pair terminal_inputs(vpiHandle gate)
{
    owner_pair pair = {NULL, NULL};
    const vpiHandle iterator = gate ? vpi_iterate(vpiPrimTerm, gate) : NULL;
    vpiHandle terminal;
    while (iterator && (terminal = vpi_scan(iterator))) {
        const vpiHandle expression = vpi_handle(vpiExpr, terminal);
        if (named(expression, "a"))
            pair.first = terminal;
        else if (named(expression, "b"))
            pair.second = terminal;
    }
    return pair;
}

static owner_pair module_paths(vpiHandle instance)
{
    owner_pair pair = {NULL, NULL};
    const vpiHandle iterator = instance ? vpi_iterate(vpiModPath, instance) : NULL;
    vpiHandle path;
    while (iterator && (path = vpi_scan(iterator))) {
        const vpiHandle terminal = first(vpiModPathIn, path);
        const vpiHandle expression = terminal ? vpi_handle(vpiExpr, terminal) : NULL;
        if (named(expression, "a"))
            pair.first = path;
        else if (named(expression, "b"))
            pair.second = path;
    }
    return pair;
}

static owner_pair timing_checks(vpiHandle instance)
{
    owner_pair pair = {NULL, NULL};
    const vpiHandle iterator = instance ? vpi_iterate(vpiTchk, instance) : NULL;
    vpiHandle check;
    while (iterator && (check = vpi_scan(iterator))) {
        const PLI_INT32 type = vpi_get(vpiTchkType, check);
        if (type == vpiSetup)
            pair.first = check;
        else if (type == vpiHold)
            pair.second = check;
    }
    return pair;
}

static int count_attributes(vpiHandle owner)
{
    int count = 0;
    const vpiHandle iterator = owner ? vpi_iterate(vpiAttribute, owner) : NULL;
    while (iterator && vpi_scan(iterator))
        ++count;
    return count;
}

static int matches_value(vpiHandle attribute, const attribute_request *request)
{
    s_vpi_value value = {0};
    value.format = vpiObjTypeVal;
    vpi_get_value(attribute, &value);
    if (value.format != request->format)
        return 0;
    if (value.format == vpiRealVal)
        return value.value.real == request->value + 0.5;
    return value.value.integer == request->value;
}

#ifdef SEED_EXTENDED_ATTRIBUTES
static void observe_owner(const char *label, const char *side, const owner_group *group,
                          vpiHandle owner, vpiHandle other, const attribute_request *requests,
                          size_t first_index, size_t expected_count)
{
    unsigned found = 0;
    int count = 0, matched = 0, verified_values = 0, good_parent = 0, sibling_parent = 0;
    const vpiHandle iterator = owner ? vpi_iterate(vpiAttribute, owner) : NULL;
    vpiHandle attribute;
    while (iterator && (attribute = vpi_scan(iterator))) {
        ++count;
        if (!of_type(attribute, vpiAttribute))
            continue;
        for (size_t offset = 0; offset < expected_count; ++offset) {
            const attribute_request *expect = &requests[first_index + offset];
            if (named(attribute, expect->name) && !(found & (1U << offset))) {
                found |= 1U << offset;
                ++matched;
                verified_values += matches_value(attribute, expect);
                const vpiHandle parent = vpi_handle(vpiParent, attribute);
                good_parent += of_type(parent, group->kind) && same(parent, owner);
                sibling_parent += same(parent, other);
            }
        }
    }
    vpi_printf((PLI_BYTE8 *)"%s %s count=%d names=%d values=%d parent=%d sibling=%d\n",
               label, side, count, matched, verified_values, good_parent, sibling_parent);
}

static int seed_and_observe(owner_group *groups)
{
    attribute_request requests[ATTRIBUTE_GROUPS * ATTRIBUTES_PER_GROUP];
    for (size_t i = 0; i < ATTRIBUTE_GROUPS; ++i) {
        const owner_group *group = &groups[i];
        if (!of_type(group->pair.first, group->kind) || !of_type(group->pair.second, group->kind) ||
            same(group->pair.first, group->pair.second))
            return 0;
        attribute_request items[ATTRIBUTES_PER_GROUP] = {
            {group->pair.first, "code", vpiIntVal, 11 + 3 * (int)i},
            {group->pair.first, "scale", vpiRealVal, 12 + 3 * (int)i},
            {group->pair.second, "mark", vpiIntVal, 13 + 3 * (int)i},
        };
        memcpy(&requests[i * ATTRIBUTES_PER_GROUP], items, sizeof items);
    }
    if (!attach_fixture_attributes(requests, ATTRIBUTE_GROUPS * ATTRIBUTES_PER_GROUP,
                                   groups[PATH_TERMINALS].pair.second, groups[MODULE_PATHS].pair.second))
        return 0;

    for (size_t i = 0; i < ATTRIBUTE_GROUPS; ++i) {
        const owner_group *group = &groups[i];
        observe_owner(group->label, "first", group, group->pair.first, group->pair.second,
                      requests, i * ATTRIBUTES_PER_GROUP, 2);
        observe_owner(group->label, "second", group, group->pair.second, group->pair.first,
                      requests, i * ATTRIBUTES_PER_GROUP + 2, 1);
    }
    return 1;
}
#endif

static void observe_gate(vpiHandle gate)
{
    const vpiHandle attribute = first(vpiAttribute, gate);
    const vpiHandle parent = attribute ? vpi_handle(vpiParent, attribute) : NULL;
    const attribute_request expected = {gate, "gate_owner", vpiIntVal, 17};
    vpi_printf((PLI_BYTE8 *)"gate attribute count=%d name=%d value=%d parent=%d\n",
               count_attributes(gate), named(attribute, expected.name),
               of_type(attribute, vpiAttribute) && matches_value(attribute, &expected), same(parent, gate));
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    const vpiHandle top = by_name(TOP);
    const vpiHandle instance = by_name(TOP ".u");
    const vpiHandle gate = first(vpiPrimitive, instance);
    const vpiHandle udp = first(vpiPrimitive, top);
    const owner_pair paths = module_paths(instance);
    owner_group groups[ATTRIBUTE_GROUPS] = {
        {"primitive-terminal", vpiPrimTerm, terminal_inputs(gate)},
        {"path-terminal", vpiPathTerm, {first(vpiModPathIn, paths.first), first(vpiModPathIn, paths.second)}},
        {"module-path", vpiModPath, paths},
        {"timing-check", vpiTchk, timing_checks(instance)},
        {"table-entry", vpiTableEntry, rows(udp)},
    };

    observe_gate(gate);
    for (size_t i = 0; i < ATTRIBUTE_GROUPS; ++i) {
        const owner_group *group = &groups[i];
        const owner_pair pair = group->pair;
        const int typed = of_type(pair.first, group->kind) && of_type(pair.second, group->kind);
        vpi_printf((PLI_BYTE8 *)"%s native typed=%d distinct=%d counts=%d/%d\n", group->label,
                   typed, pair.first && pair.second && !same(pair.first, pair.second),
                   count_attributes(pair.first), count_attributes(pair.second));
    }
#ifdef SEED_EXTENDED_ATTRIBUTES
    if (!seed_and_observe(groups))
        vpi_printf((PLI_BYTE8 *)"could not seed attributes\n");
    observe_gate(gate);
#endif
    return 0;
}
#else
static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf((PLI_BYTE8 *)"attribute VPI declarations unavailable\n");
    return 0;
}
#endif

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_extended_attributes";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
