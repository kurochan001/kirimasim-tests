#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "sv_vpi_user.h"

int foreign_increment(int value)
{
    return value + 1;
}

int legacy_helper(int value)
{
    return value + 4;
}

static void show(const char *description, const char *path, PLI_INT32 language)
{
    vpiHandle handle = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    if (handle == NULL) {
        vpi_printf("%s missing declaration\n", description);
        return;
    }
    int language_matches = vpi_get(vpiDPICStr, handle) == language;
    const char *linkage = vpi_get_str(vpiDPICIdentifier, handle);
    vpi_printf("%s language=%d linkage=%s\n", description, language_matches,
               linkage == NULL ? "<none>" : linkage);
}

static PLI_INT32 observe(p_cb_data callback)
{
    (void)callback;
    show("C import", "test_vpi_dpi_language_and_linkage_name_for_imports_and_exports.local_import", vpiDPIC);
    show("legacy import", "test_vpi_dpi_language_and_linkage_name_for_imports_and_exports.legacy_import", vpiDPI);
    show("C export", "test_vpi_dpi_language_and_linkage_name_for_imports_and_exports.local_export", vpiDPIC);
    show("legacy export", "test_vpi_dpi_language_and_linkage_name_for_imports_and_exports.sv_legacy_export", vpiDPI);
    return 0;
}

static void register_observation(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_observation, NULL};

#ifdef __cplusplus
}
#endif
