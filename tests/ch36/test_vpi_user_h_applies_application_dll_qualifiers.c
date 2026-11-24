#include <stddef.h>

/* Each qualifier inserts a declaration. The references precede the definitions,
 * so simply leaving the macros defined without expanding them cannot pass. */
#define PLI_EXTERN
#define PLI_DLLISPEC extern int header_import_qualifier_seen;
#define PLI_VEXTERN
#define PLI_DLLESPEC extern int startup_export_qualifier_seen; extern
#include "vpi_user.h"

#if defined(PLI_DLLISPEC) && defined(PLI_DLLESPEC)
#define APPLICATION_QUALIFIERS_KEPT 1
#else
#define APPLICATION_QUALIFIERS_KEPT 0
#endif

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 observe(p_cb_data callback)
{
    (void)callback;
    vpi_printf("header import qualifier=%d startup export qualifier=%d\n",
               header_import_qualifier_seen == 29, startup_export_qualifier_seen == 37);
    vpi_printf("provided qualifiers remain defined=%d\n", APPLICATION_QUALIFIERS_KEPT);
    return 0;
}

static void install(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif

int header_import_qualifier_seen = 29;
int startup_export_qualifier_seen = 37;
