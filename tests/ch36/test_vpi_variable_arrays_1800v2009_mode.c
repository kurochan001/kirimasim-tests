/* VPI application of test_vpi_variable_arrays_1800v2009_mode (IEEE 1800-2023 36.12.1, 36.12.2.1). */
/* The compatibility mode 1800v2009, selected before any VPI header (36.12.2.1). */
#define VPI_COMPATIBILITY_VERSION_1800v2009 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_arrays_1800v2009_mode"
#define MAX_ITEMS 16

/* The application's own names: vpiLogicVar is vpiReg, vpiArrayVar is vpiRegArray. */
static const char *type_name(PLI_INT32 type)
{
    switch (type) {
    case vpiReg: return "vpiReg";
    case vpiRegArray: return "vpiRegArray";
    case vpiMemory: return "vpiMemory";
    case vpiMemoryWord: return "vpiMemoryWord";
    case vpiIntegerVar: return "vpiIntegerVar";
    case vpiTimeVar: return "vpiTimeVar";
    case vpiRealVar: return "vpiRealVar";
    case vpiRefObj: return "vpiRefObj";
    case vpiVirtualInterfaceVar: return "vpiVirtualInterfaceVar";
    default: return "other";
    }
}

typedef struct {
    int count;
    char items[MAX_ITEMS][48];
} text_list;

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

/* Adds text once. */
static void add(text_list *list, const char *text)
{
    int k;
    for (k = 0; k < list->count && k < MAX_ITEMS; k++)
        if (strcmp(list->items[k], text) == 0)
            return;
    if (list->count < MAX_ITEMS)
        snprintf(list->items[list->count], sizeof list->items[0], "%s", text);
    list->count++;
}

static void print_list(text_list *list, const char *sep)
{
    int k, shown = list->count < MAX_ITEMS ? list->count : MAX_ITEMS;
    qsort(list->items, shown, sizeof list->items[0], by_text);
    for (k = 0; k < shown; k++)
        vpi_printf("%s%s", k ? sep : "", list->items[k]);
}

static vpiHandle find(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name(full, NULL);
}

static const char *type_of(const char *name)
{
    vpiHandle h = find(name);
    return h == NULL ? "not found" : type_name(vpi_get(vpiType, h));
}

static int is_named(vpiHandle obj, const char *name)
{
    const char *n = vpi_get_str(vpiName, obj);
    return n != NULL && strcmp(n, name) == 0;
}

/* Counts the objects of an iteration and collects their distinct types. */
static void count_types(const char *label, PLI_INT32 relation, vpiHandle ref)
{
    text_list types;
    int n = 0;
    vpiHandle it = ref == NULL ? NULL : vpi_iterate(relation, ref), obj;

    memset(&types, 0, sizeof types);
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        n++;
        add(&types, type_name(vpi_get(vpiType, obj)));
    }
    vpi_printf("%s: %d objects, types ", label, n);
    print_list(&types, "/");
    vpi_printf("\n");
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle scope = find("u_cls");
    vpiHandle it, obj, defn = NULL;
    text_list names, types;
    int mem_found = 0;

    (void)data;
    if (top == NULL) {
        vpi_printf("top module not found\n");
        return 0;
    }
    vpi_printf("types: mem %s, ia %s, ta %s, ra %s, lv %s, iv %s, tv %s, rv %s\n",
               type_of("mem"), type_of("ia"), type_of("ta"), type_of("ra"),
               type_of("lv"), type_of("iv"), type_of("tv"), type_of("rv"));

    /* rows 1 and 2 of Table 36-10 */
    memset(&types, 0, sizeof types);
    it = vpi_iterate(vpiMemory, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        if (is_named(obj, "mem"))
            mem_found = 1;
        add(&types, type_name(vpi_get(vpiType, obj)));
    }
    vpi_printf("vpiMemory of the module: mem among them %d, types ", mem_found);
    print_list(&types, "/");
    vpi_printf("\n");
    count_types("vpiMemoryWord of mem", vpiMemoryWord, find("mem"));

    /* row 5 */
    memset(&names, 0, sizeof names);
    it = vpi_iterate(vpiVariables, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        char item[48];
        const char *name = vpi_get_str(vpiName, obj);
        snprintf(item, sizeof item, "%s:%s", name ? name : "?",
                 type_name(vpi_get(vpiType, obj)));
        add(&names, item);
    }
    vpi_printf("vpiVariables of the module: ");
    print_list(&names, " ");
    vpi_printf("\n");

    /* row 6 */
    count_types("vpiReg of mem", vpiReg, find("mem"));
    count_types("vpiReg of ia", vpiReg, find("ia"));
    count_types("vpiReg of ta", vpiReg, find("ta"));
    count_types("vpiReg of ra", vpiReg, find("ra"));

    /* row 7 */
    memset(&names, 0, sizeof names);
    it = vpi_iterate(vpiRegArray, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        const char *name = vpi_get_str(vpiName, obj);
        add(&names, name ? name : "?");
    }
    vpi_printf("vpiRegArray of the module: ");
    print_list(&names, " ");
    vpi_printf("\n");

    /* rows 8 and 9 */
    it = scope == NULL ? NULL : vpi_iterate(vpiClassDefn, scope);
    while (it != NULL && (obj = vpi_scan(it)) != NULL)
        if (is_named(obj, "holder"))
            defn = obj;
    vpi_printf("class defn holder found: %d\n", defn != NULL);
    count_types("vpiInterfaceDecl of the class defn", vpiInterfaceDecl, defn);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
