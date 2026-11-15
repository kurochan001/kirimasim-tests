/* Observe declared primitive-array indices, identity and terminal values.
 * IEEE 1800-2023 28.3.5, 28.3.6, 37.11, 37.35 and 38.3/19/21.
 * Element names and iterator order are deliberately not observed. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define LIMIT 8
typedef struct item_s {
    int index;
    vpiHandle handle;
} item;

static int phase;

static int compare_index(const void *a, const void *b)
{
    int x = ((const item *)a)->index, y = ((const item *)b)->index;
    return (x > y)-(x < y);
}

static int integer(vpiHandle h)
{
    s_vpi_value value;
    value.format = vpiIntVal;
    vpi_get_value(h, &value);
    return (int)value.value.integer;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiGateArray: return "gate";
    case vpiSwitchArray: return "switch";
    case vpiUdpArray: return "udp";
    default: return "other";
    }
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call ? vpi_handle(vpiScope, call) : NULL;
    vpiHandle array = scope ? vpi_handle_by_name((PLI_BYTE8 *)"g", scope) : NULL;
    vpiHandle scalar = scope ? vpi_handle_by_name((PLI_BYTE8 *)"scalar", scope) : NULL;
    vpiHandle left, right, iterator, h;
    item entries[LIMIT];
    int n = 0, duplicate = 0, i, j;
    (void)unused;
    if (!array) {
        vpi_printf((PLI_BYTE8 *)"p%d array missing\n", phase++);
        return 0;
    }
    left = vpi_handle(vpiLeftRange, array);
    right = vpi_handle(vpiRightRange, array);
    if (!left || !right) {
        vpi_printf((PLI_BYTE8 *)"p%d bounds missing\n", phase++);
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"p%d kind=%s range=%d:%d size=%d\n", phase,
               kind(array), integer(left), integer(right), (int)vpi_get(vpiSize, array));
    iterator = vpi_iterate(vpiPrimitive, array);
    while (iterator && (h = vpi_scan(iterator)) != NULL) {
        vpiHandle index = vpi_handle(vpiIndex, h);
        if (n == LIMIT || !index) {
            vpi_printf((PLI_BYTE8 *)"invalid element or overflow\n");
            return 0;
        }
        entries[n].index = integer(index);
        entries[n].handle = h;
        for (j = 0; j < n; j++)
            if (vpi_compare_objects(h, entries[j].handle))
                duplicate = 1;
        n++;
    }
    qsort(entries, (size_t)n, sizeof entries[0], compare_index);
    vpi_printf((PLI_BYTE8 *)"elements=%d duplicate=%d\n", n, duplicate);
    for (i = 0; i < n; i++) {
        vpiHandle parent = vpi_handle(vpiPrimitiveArray, entries[i].handle);
        vpiHandle indexed = vpi_handle_by_index(array, entries[i].index);
        vpiHandle terms = vpi_iterate(vpiPrimTerm, entries[i].handle), term;
        item terminals[LIMIT];
        int count = 0;
        while (terms && (term = vpi_scan(terms)) != NULL) {
            if (count == LIMIT) {
                vpi_printf((PLI_BYTE8 *)"terminal overflow\n");
                return 0;
            }
            terminals[count].index = (int)vpi_get(vpiTermIndex, term);
            terminals[count++].handle = term;
        }
        qsort(terminals, (size_t)count, sizeof terminals[0], compare_index);
        vpi_printf((PLI_BYTE8 *)"index=%d parent=%d lookup=%d terms=%d", entries[i].index,
                   parent && vpi_compare_objects(parent, array),
                   indexed && vpi_compare_objects(indexed, entries[i].handle), count);
        for (j = 0; j < count; j++)
            vpi_printf((PLI_BYTE8 *)" t%d=%d", terminals[j].index,
                       integer(terminals[j].handle));
        vpi_printf((PLI_BYTE8 *)"\n");
    }
    vpi_printf((PLI_BYTE8 *)"scalar present=%d index_null=%d\n", scalar != NULL,
               scalar && vpi_handle(vpiIndex, scalar) == NULL);
    phase++;
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data data;
    memset(&data, 0, sizeof data);
    data.type = vpiSysTask;
    data.tfname = (PLI_BYTE8 *)"$primitive_array_identity";
    data.calltf = inspect;
    vpi_register_systf(&data);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
