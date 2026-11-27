#define _DARWIN_C_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#define HOST_DEFAULT "KIRIMASIM_TEST_HOST_VPI_DEFAULT"

static PLI_INT32 (*host_get)(PLI_INT32, vpiHandle);
static vpiHandle (*host_iterate)(PLI_INT32, vpiHandle);
static vpiHandle (*host_scan)(vpiHandle);

/* A Mach-O dependency of unbound applications. Compile-bound symbols bypass it. */
__attribute__((constructor))
static void choose_default(void)
{
    const char *mode = getenv(HOST_DEFAULT);
    const int legacy = mode != NULL && strcmp(mode, "legacy") == 0;
    if (mode == NULL || (!legacy && strcmp(mode, "current") != 0)) {
        fputs("host default requires exactly one compatibility mode\n", stderr);
        return;
    }
    host_get = (PLI_INT32 (*)(PLI_INT32, vpiHandle))
        dlsym(RTLD_MAIN_ONLY, legacy ? "vpi_get_1364v1995" : "vpi_get");
    host_iterate = (vpiHandle (*)(PLI_INT32, vpiHandle))
        dlsym(RTLD_MAIN_ONLY, legacy ? "vpi_iterate_1364v1995" : "vpi_iterate");
    host_scan = (vpiHandle (*)(vpiHandle))
        dlsym(RTLD_MAIN_ONLY, legacy ? "vpi_scan_1364v1995" : "vpi_scan");
    if (host_get == NULL || host_iterate == NULL || host_scan == NULL)
        fputs("host default compatibility entry points are unavailable\n", stderr);
}

PLI_INT32 vpi_get(PLI_INT32 property, vpiHandle object)
{
    return host_get == NULL ? vpiUndefined : host_get(property, object);
}

vpiHandle vpi_iterate(PLI_INT32 relation, vpiHandle object)
{
    return host_iterate == NULL ? NULL : host_iterate(relation, object);
}

vpiHandle vpi_scan(vpiHandle iterator)
{
    return host_scan == NULL ? NULL : host_scan(iterator);
}
