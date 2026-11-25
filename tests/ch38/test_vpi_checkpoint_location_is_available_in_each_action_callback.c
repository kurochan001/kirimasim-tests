#include <stddef.h>
#include <string.h>
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 report_location(p_cb_data callback)
{
    const PLI_BYTE8 *location = vpi_get_str(vpiSaveRestartLocation, NULL);
    const char *slash = location != NULL ? strrchr(location, '/') : NULL;
    const char *basename = slash != NULL ? slash + 1 : location;
    vpi_printf("%s path=%d\n", (const char *)callback->user_data,
               basename != NULL && strcmp(basename, "callback-location.chk") == 0);
    return 0;
}

static void install(void)
{
    static char start_save[] = "start save";
    static char end_save[] = "end save";
    static char start_restart[] = "start restart";
    static char end_restart[] = "end restart";
    register_action(cbStartOfSave, report_location, start_save);
    register_action(cbEndOfSave, report_location, end_save);
    register_action(cbStartOfRestart, report_location, start_restart);
    register_action(cbEndOfRestart, report_location, end_restart);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
