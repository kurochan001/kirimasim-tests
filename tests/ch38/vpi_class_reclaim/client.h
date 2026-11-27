#ifndef TEST_VPI_RECLAIM_CLIENT_H
#define TEST_VPI_RECLAIM_CLIENT_H

#include "vpi_user.h"
#include "sv_vpi_user.h"

typedef struct reclaim_observation {
    int reason, no_time, typed, dynamic, automatic_storage, clear;
    PLI_INT64 id;
} reclaim_observation;

static inline reclaim_observation observe_callback(
    const s_cb_data *data, PLI_INT32 (*get)(PLI_INT32, vpiHandle),
    PLI_INT64 (*get64)(PLI_INT32, vpiHandle))
{
    reclaim_observation result = {0};
    result.reason = data->reason;
    result.no_time = data->time == NULL;
    if (data->obj != NULL) {
        result.typed = get(vpiType, data->obj) == vpiClassObj;
        result.dynamic = get(vpiAllocScheme, data->obj) == vpiDynamicScheme;
        result.automatic_storage = get(vpiAutomatic, data->obj) == 1;
        result.clear = get(vpiIsProtected, data->obj) == 0;
        result.id = get64(vpiObjId, data->obj);
    }
    return result;
}

#endif
