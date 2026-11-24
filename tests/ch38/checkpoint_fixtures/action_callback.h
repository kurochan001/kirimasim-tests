#ifndef TEST_CHECKPOINT_ACTION_CALLBACK_H
#define TEST_CHECKPOINT_ACTION_CALLBACK_H

#include "vpi_user.h"

static vpiHandle register_action(PLI_INT32 reason, PLI_INT32 (*routine)(p_cb_data), void *data)
{
    s_cb_data callback = {0};
    callback.reason = reason;
    callback.cb_rtn = routine;
    callback.user_data = (PLI_BYTE8 *)data;
    return vpi_register_cb(&callback);
}

static inline void register_probe(const char *name, PLI_INT32 (*routine)(PLI_BYTE8 *))
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)name;
    task.calltf = routine;
    vpi_register_systf(&task);
}

#endif
