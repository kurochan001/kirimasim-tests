#include <stddef.h>

#define STRINGIFY_TOKENS(...) #__VA_ARGS__
#define EXPANDED_TOKENS(...) STRINGIFY_TOKENS(__VA_ARGS__)

/* The startup declaration expands this qualifier while both defaults are defined.
 * A static linkage default also conflicts with the external marker definition. */
#define PLI_DLLESPEC                                                             \
    char default_external_linkage[                                              \
        sizeof(EXPANDED_TOKENS(PLI_EXTERN)) == 1 &&                               \
        sizeof(EXPANDED_TOKENS(PLI_VEXTERN)) == sizeof("extern") ? 1 : -1];        \
    extern
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 observe(p_cb_data callback)
{
    (void)callback;
    vpi_printf("default external linkage=%d\n", (int)default_external_linkage[0]);
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

char default_external_linkage[1] = {1};
