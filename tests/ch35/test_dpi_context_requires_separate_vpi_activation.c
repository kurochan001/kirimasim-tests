#include <stdio.h>
#include "svdpi.h"
#include "vpi_user.h"

#ifdef __cplusplus
extern "C"
#endif
int read_vpi_marker(int *context_active, int *released)
{
    const svScope scope = svGetScope();
    *context_active = scope != NULL;
    *released = 0;
#ifdef DPI_CONTEXT_ONLY
    return -3;
#else
    char path[256];
    const char *name = scope ? svGetNameFromScope(scope) : NULL;
    if (name == NULL)
        return -1;
    const int length = snprintf(path, sizeof path, "%s.marker", name);
    if (length < 0 || length >= (int)sizeof path)
        return -2;
    vpiHandle variable = vpi_handle_by_name(path, NULL);
    if (variable == NULL)
        return -4;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(variable, &value);
    *released = vpi_release_handle(variable);
    return value.value.integer;
#endif
}
