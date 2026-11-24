#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 record_unknown(p_cb_data data)
{
    const char *name = data->user_data;
    if (name != NULL && name[0] == '$')
        ++name;
    vpi_printf("unresolved reason=%d name=%s\n",
               data->reason == cbUnresolvedSystf, name != NULL ? name : "NULL");
    return 0;
}

static void watch_unknown(void)
{
    static PLI_BYTE8 registration_context[] = "registration context";
    s_cb_data registration = {0};
    registration.reason = cbUnresolvedSystf;
    registration.cb_rtn = record_unknown;
    registration.user_data = registration_context;
    vpi_register_cb(&registration);
}

void (*vlog_startup_routines[])(void) = {watch_unknown, NULL};

#ifdef __cplusplus
}
#endif
