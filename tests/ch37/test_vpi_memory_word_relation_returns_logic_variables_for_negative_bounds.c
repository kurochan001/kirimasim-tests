#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call == NULL ? NULL : vpi_handle(vpiScope, call);
    vpiHandle array = scope == NULL ? NULL : vpi_handle_by_name((PLI_BYTE8 *)"locations", scope);
    vpiHandle iterator, word, selected;
    s_vpi_value value = {0};
    int words = 0, modern = 0, parents = 0, found = 0;
    (void)unused;

    if (array == NULL)
        return 0;
    selected = vpi_handle_by_index(array, -1);
    iterator = vpi_iterate(vpiMemoryWord, array);
    if (iterator == NULL || selected == NULL)
        return 0;
    while ((word = vpi_scan(iterator)) != NULL) {
        int type = vpi_get(vpiType, word);
        vpiHandle parent = vpi_handle(vpiParent, word);
        words++;
        modern += type == vpiReg || type == vpiLogicVar;
        parents += parent != NULL && vpi_compare_objects(parent, array);
        found += vpi_compare_objects(word, selected);
    }

    value.format = vpiIntVal;
    vpi_get_value(selected, &value);
    vpi_printf("words=%d modern=%d parents=%d selected=%d value=%d\n",
               words, modern, parents, found, (int)value.value.integer);
    value.value.integer = 0x72;
    vpi_put_value(selected, &value, NULL, vpiNoDelay);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_words";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
