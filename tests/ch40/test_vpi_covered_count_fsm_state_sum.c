/* IEEE 1800-2023 40.5.2: match state counts and their sum across two samples. */
#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_covered_count_fsm_state_sum"
enum { STATE_COUNT = 4 };

struct sample {
    int total, counts[STATE_COUNT], valid;
};

static struct sample samples[2];
static int index_to_sample[2] = {0, 1};

static PLI_INT32 take_sample(p_cb_data callback)
{
    int index;
    if (callback->user_data == (PLI_BYTE8 *)&index_to_sample[0])
        index = 0;
    else if (callback->user_data == (PLI_BYTE8 *)&index_to_sample[1])
        index = 1;
    else
        return 0;
    struct sample *sample = &samples[index];
    vpiHandle scope = vpi_handle_by_name((PLI_BYTE8 *)TOP ".counted", NULL);
    vpiHandle fsms = scope ? vpi_iterate(vpiFsm, scope) : NULL;
    vpiHandle fsm = fsms ? vpi_scan(fsms) : NULL;
    vpiHandle states = fsm ? vpi_iterate(vpiFsmStates, fsm) : NULL;
    vpiHandle state;
    unsigned mask = 0;
    int visited_handles = 0, sum = 0, valid_counts = 1;

    if (fsm)
        vpi_release_handle(fsms);
    sample->total = fsm ? vpi_get(vpiCoveredCount, fsm) : vpiUndefined;
    while (states && (state = vpi_scan(states))) {
        s_vpi_value value = {0};
        int count = vpi_get(vpiCoveredCount, state);
        int code;

        value.format = vpiIntVal;
        vpi_get_value(state, &value);
        code = value.value.integer;
        visited_handles++;
        if (code < 0 || code >= STATE_COUNT || count < 0) {
            valid_counts = 0;
            continue;
        }
        mask |= 1u << code;
        sample->counts[code] = count;
        sum += count;
    }
    sample->valid = valid_counts && visited_handles == STATE_COUNT &&
                    mask == (1u << STATE_COUNT) - 1u && sample->total == sum;
    if (index == 1) {
        const struct sample *first = &samples[0];
        vpi_printf("fsm: first_sum=%d final_sum=%d added=%d\n",
                   first->valid, sample->valid, sample->total - first->total);
        vpi_printf("states added=%d,%d,%d,%d unused_count=%d\n",
                   sample->counts[0] - first->counts[0], sample->counts[1] - first->counts[1],
                   sample->counts[2] - first->counts[2], sample->counts[3] - first->counts[3],
                   sample->counts[3]);
    }
    return 0;
}

static PLI_INT32 schedule(p_cb_data ignored)
{
    static s_vpi_time ticks[2] = {{vpiSimTime, 0, 3, 0.0}, {vpiSimTime, 0, 11, 0.0}};
    (void)ignored;
    for (int index = 0; index < 2; index++) {
        s_cb_data callback = {0};
        callback.reason = cbReadOnlySynch;
        callback.time = &ticks[index];
        callback.user_data = (PLI_BYTE8 *)&index_to_sample[index];
        callback.cb_rtn = take_sample;
        vpi_register_cb(&callback);
    }
    return 0;
}

static void register_all(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = schedule;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_all, NULL};

#ifdef __cplusplus
}
#endif
