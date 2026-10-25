/* VPI application of test_vpi_variable_arrays_1364v2001_mode (IEEE 1800-2023 36.12.1, 36.12.2.1). */
/* The compatibility mode 1364v2001, selected before any VPI header (36.12.2.1). */
#define VPI_COMPATIBILITY_VERSION_1364v2001 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_arrays_1364v2001_mode"
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
    vpiHandle it, obj;
    text_list types;
    int mem_found = 0;

    (void)data;
    if (top == NULL) {
        vpi_printf("top module not found\n");
        return 0;
    }

    vpiHandle mem = find("mem"), word;
    PLI_INT32 type;

    vpi_printf("types: ia %s, ta %s, ra %s, rg %s, iv %s, tv %s, rv %s\n",
               type_of("ia"), type_of("ta"), type_of("ra"),
               type_of("rg"), type_of("iv"), type_of("tv"), type_of("rv"));

    /* rows 1 and 2 of Table 36-10: either form */
    type = mem == NULL ? 0 : vpi_get(vpiType, mem);
    vpi_printf("mem is a vpiMemory or a vpiRegArray: %d\n",
               type == vpiMemory || type == vpiRegArray);
    word = mem == NULL ? NULL : vpi_handle_by_index(mem, 0);
    type = word == NULL ? 0 : vpi_get(vpiType, word);
    vpi_printf("mem word 0 (vpi_handle_by_index) is a vpiMemoryWord or a vpiReg: %d\n",
               type == vpiMemoryWord || type == vpiReg);

    /* row 5 */
    {
        int iv = 0, rv = 0, tv = 0, named = 0, regs = 0;
        it = vpi_iterate(vpiVariables, top);
        while (it != NULL && (obj = vpi_scan(it)) != NULL) {
            PLI_INT32 type = vpi_get(vpiType, obj);
            iv |= is_named(obj, "iv");
            rv |= is_named(obj, "rv");
            tv |= is_named(obj, "tv");
            named |= is_named(obj, "rg");
            regs |= type == vpiReg || type == vpiRegArray;
        }
        vpi_printf("vpiVariables of the module: iv rv tv among them %d, rg among them %d, "
                   "vpiReg or vpiRegArray objects %d\n", iv && rv && tv, named, regs);
    }

    /* rows 6 and 7 */
    {
        int others = 0, arrays = 0;
        vpiHandle elems, elem;
        it = vpi_iterate(vpiRegArray, top);
        while (it != NULL && (obj = vpi_scan(it)) != NULL) {
            arrays |= is_named(obj, "ia") || is_named(obj, "ta") || is_named(obj, "ra");
            elems = vpi_iterate(vpiReg, obj);
            while (elems != NULL && (elem = vpi_scan(elems)) != NULL)
                others += vpi_get(vpiType, elem) != vpiReg;
        }
        vpi_printf("vpiReg of each vpiRegArray of the module: objects other than vpiReg %d\n",
                   others);
        vpi_printf("vpiRegArray of the module: ia ta ra among them %d\n", arrays);
    }
    (void)mem_found;
    (void)types;
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
