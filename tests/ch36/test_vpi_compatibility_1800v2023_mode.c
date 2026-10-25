/* VPI application of test_vpi_compatibility_1800v2023_mode
   (IEEE 1800-2023 36.12.2.1, 36.12.1, L.2). */
/* The one compatibility macro, defined as 1 before any VPI header. */
#define VPI_COMPATIBILITY_VERSION_1800v2023 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef VPI_COMPATIBILITY_H
#define COMPATIBILITY_INCLUDED 1
#else
#define COMPATIBILITY_INCLUDED 0
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_compatibility_1800v2023_mode"
#define MAX_ITEMS 16

#define VT_STR(x) #x
#define VT_XSTR(x) VT_STR(x)
#define SHOW(f) vpi_printf((PLI_BYTE8 *)"%s calls %s\n", #f, VT_XSTR(f))

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
    case vpiClassTypespec: return "vpiClassTypespec";
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

static void print_list(text_list *list)
{
    int k, shown = list->count < MAX_ITEMS ? list->count : MAX_ITEMS;
    qsort(list->items, shown, sizeof list->items[0], by_text);
    for (k = 0; k < shown; k++)
        vpi_printf((PLI_BYTE8 *)"%s%s", k ? " " : "", list->items[k]);
}

static vpiHandle find(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *type_of(const char *name)
{
    vpiHandle h = find(name);
    return h == NULL ? "not found" : type_name(vpi_get(vpiType, h));
}

static const char *name_of(vpiHandle obj)
{
    const char *n = vpi_get_str(vpiName, obj);
    return n != NULL ? n : "?";
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
    vpi_printf((PLI_BYTE8 *)"%s: %d objects, types ", label, n);
    print_list(&types);
    vpi_printf((PLI_BYTE8 *)"\n");
}

/* Prints "name type" for each object of an iteration, or NULL. */
static void list_objects(const char *label, PLI_INT32 relation, vpiHandle ref)
{
    text_list items;
    vpiHandle it = ref == NULL ? NULL : vpi_iterate(relation, ref), obj;

    vpi_printf((PLI_BYTE8 *)"%s: ", label);
    if (it == NULL) {
        vpi_printf((PLI_BYTE8 *)"NULL\n");
        return;
    }
    memset(&items, 0, sizeof items);
    while ((obj = vpi_scan(it)) != NULL) {
        char item[48];
        snprintf(item, sizeof item, "%s %s", name_of(obj), type_name(vpi_get(vpiType, obj)));
        add(&items, item);
    }
    print_list(&items);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle cls = find("u_cls");
    vpiHandle h = find("u_cls.h");
    vpiHandle it, obj, defn = NULL, ts;
    text_list names, types;
    int mem_found = 0;

    (void)data;
    if (top == NULL || cls == NULL) {
        vpi_printf((PLI_BYTE8 *)"top module or u_cls not found\n");
        return 0;
    }
    /* rows 1, 3 and 4 */
    vpi_printf((PLI_BYTE8 *)"types: mem %s, ia %s, ta %s, ra %s, lv %s, iv %s, tv %s, rv %s\n",
               type_of("mem"), type_of("ia"), type_of("ta"), type_of("ra"),
               type_of("lv"), type_of("iv"), type_of("tv"), type_of("rv"));

    /* rows 1 and 2 */
    memset(&types, 0, sizeof types);
    it = vpi_iterate(vpiMemory, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        if (strcmp(name_of(obj), "mem") == 0)
            mem_found = 1;
        add(&types, type_name(vpi_get(vpiType, obj)));
    }
    vpi_printf((PLI_BYTE8 *)"vpiMemory of the module: mem among them %d, types ", mem_found);
    print_list(&types);
    vpi_printf((PLI_BYTE8 *)"\n");
    count_types("vpiMemoryWord of mem", vpiMemoryWord, find("mem"));

    /* row 5 */
    memset(&names, 0, sizeof names);
    it = vpi_iterate(vpiVariables, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        char item[48];
        snprintf(item, sizeof item, "%s:%s", name_of(obj), type_name(vpi_get(vpiType, obj)));
        add(&names, item);
    }
    vpi_printf((PLI_BYTE8 *)"vpiVariables of the module: ");
    print_list(&names);
    vpi_printf((PLI_BYTE8 *)"\n");

    /* row 6 */
    count_types("vpiReg of ia", vpiReg, find("ia"));
    count_types("vpiReg of ta", vpiReg, find("ta"));
    count_types("vpiReg of ra", vpiReg, find("ra"));

    /* row 7 */
    memset(&names, 0, sizeof names);
    it = vpi_iterate(vpiRegArray, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL)
        add(&names, name_of(obj));
    vpi_printf((PLI_BYTE8 *)"vpiRegArray of the module: ");
    print_list(&names);
    vpi_printf((PLI_BYTE8 *)"\n");

    /* row 8 */
    it = vpi_iterate(vpiClassDefn, cls);
    while (it != NULL && (obj = vpi_scan(it)) != NULL)
        if (strcmp(name_of(obj), "holder") == 0)
            defn = obj;
    vpi_printf((PLI_BYTE8 *)"class defn holder found: %d\n", defn != NULL);
    if (defn != NULL)
        list_objects("vpiInterfaceDecl of the class defn", vpiInterfaceDecl, defn);

    /* row 9 */
    ts = h == NULL ? NULL : vpi_handle(vpiTypespec, h);
    vpi_printf((PLI_BYTE8 *)"typespec of h: %s\n",
               ts == NULL ? "NULL" : type_name(vpi_get(vpiType, ts)));
    if (ts != NULL)
        list_objects("vpiInterfaceDecl of the class typespec", vpiInterfaceDecl, ts);
    return 0;
}

static void startup(void)
{
    s_cb_data d;

    vpi_printf((PLI_BYTE8 *)"VPI_COMPATIBILITY_H %d\n", COMPATIBILITY_INCLUDED);
    SHOW(vpi_compare_objects);
    SHOW(vpi_control);
    SHOW(vpi_get);
    SHOW(vpi_get_str);
    SHOW(vpi_get_value);
    SHOW(vpi_handle);
    SHOW(vpi_handle_by_index);
    SHOW(vpi_handle_by_multi_index);
    SHOW(vpi_handle_by_name);
    SHOW(vpi_handle_multi);
    SHOW(vpi_iterate);
    SHOW(vpi_put_value);
    SHOW(vpi_register_cb);
    SHOW(vpi_scan);

    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {startup, 0};

#ifdef __cplusplus
}
#endif
