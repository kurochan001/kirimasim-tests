#define _POSIX_C_SOURCE 200809L
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifndef TEST_APPLICATION
#define TEST_APPLICATION "native-default"
#endif

#define HOST_DEFAULT "KIRIMASIM_TEST_HOST_VPI_DEFAULT"

#ifdef __cplusplus
extern "C" {
#endif

static unsigned variables(vpiHandle module)
{
    vpiHandle iterator = vpi_iterate(vpiVariables, module), item;
    unsigned present = 0;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        const char *name = vpi_get_str(vpiName, item);
        if (name == NULL)
            continue;
        if (strcmp(name, "counter") == 0)
            present |= 1;
        if (strcmp(name, "standalone") == 0)
            present |= 2;
        if (strcmp(name, "storage") == 0)
            present |= 4;
    }
    return present;
}

static PLI_INT32 report(p_cb_data cb)
{
    (void)cb;
    vpiHandle module = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_host_default_and_compile_bound_modes", NULL);
    vpiHandle memory = module == NULL ? NULL : vpi_handle_by_name((PLI_BYTE8 *)"storage", module);
    vpiHandle word = memory == NULL ? NULL : vpi_handle_by_index(memory, 1);
    s_vpi_value data = {.format = vpiIntVal};
    if (word != NULL)
        vpi_get_value(word, &data);
    vpi_printf("%s array=%d word=%d value=%d variables=%u\n", TEST_APPLICATION,
               memory == NULL ? -1 : (int)vpi_get(vpiType, memory),
               word == NULL ? -1 : (int)vpi_get(vpiType, word),
               (int)data.value.integer, module == NULL ? 0u : variables(module));
#ifdef TEST_CHANGE_ENVIRONMENT
    const char *mode = getenv(HOST_DEFAULT);
    if (mode != NULL) {
        const char *replacement = strcmp(mode, "legacy") == 0 ? "current" : "legacy";
        if (setenv(HOST_DEFAULT, replacement, 1) == 0)
            vpi_printf("environment changed=%s\n", replacement);
    }
#endif
    return 0;
}

static void register_probe(void)
{
    s_cb_data callback = {0};
    callback.reason = cbEndOfSimulation;
    callback.cb_rtn = report;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_probe, NULL};

#ifdef __cplusplus
}
#endif
