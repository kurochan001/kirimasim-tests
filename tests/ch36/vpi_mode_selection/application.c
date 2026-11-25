#ifndef COMPATIBILITY_FROM_FLAGS
#define VPI_COMPATIBILITY_VERSION_1364v2001 1
#endif

#include <stddef.h>
#include "vpi_user.h"
#include "vpi_user.h"

#define VPI_NAME_LITERAL(symbol) #symbol
#define VPI_NAME(symbol) VPI_NAME_LITERAL(symbol)

#ifdef __cplusplus
extern "C" {
#endif

PLI_INT32 vpi_mode_selection_callback(struct t_cb_data *data);

static void vpi_mode_selection_startup(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = vpi_mode_selection_callback;
#ifdef VPI_COMPATIBILITY_H
    vpi_printf("application %s guard=1\n", VPI_NAME(vpi_get));
#else
    vpi_printf("application %s guard=0\n", VPI_NAME(vpi_get));
#endif
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {vpi_mode_selection_startup, NULL};

#ifdef __cplusplus
}
#endif

#ifndef COMPATIBILITY_SEPARATE_SOURCES
#include "callback.c"
#endif
