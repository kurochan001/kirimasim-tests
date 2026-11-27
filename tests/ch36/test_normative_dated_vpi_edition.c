/* The ordinary suite entry uses the explicitly cited edition. The reference
   runner supplies the resolved or contrast edition before this header. */
#include <stddef.h>

#ifndef FROM_REFERENCE_CATALOG
#define VPI_COMPATIBILITY_VERSION_1364v1995 1
#endif
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define STRINGIFY(x) #x
#define SYMBOL(x) STRINGIFY(x)

static PLI_INT32 read_memory(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle array = vpi_handle_by_name((PLI_BYTE8 *)"test_normative_dated_vpi_edition.samples", NULL);
    vpiHandle word = array ? vpi_handle_by_index(array, 3) : NULL;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    if (word) vpi_get_value(word, &value);
    vpi_printf((PLI_BYTE8 *)"lookup=%s\n", SYMBOL(vpi_handle_by_name));
    vpi_printf((PLI_BYTE8 *)"array=%d element=%d value=%d\n",
               array ? vpi_get(vpiType, array) : -1, word ? vpi_get(vpiType, word) : -1,
               word ? value.value.integer : -1);
    return 0;
}

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_normative_edition";
    task.calltf = read_memory;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
