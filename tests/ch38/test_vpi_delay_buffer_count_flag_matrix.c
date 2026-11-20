#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_delay_buffer_count_flag_matrix"
#define GUARD_BYTE 0xA5

static int guard_intact(const s_vpi_time *entry)
{
    const unsigned char *bytes = (const unsigned char *)entry;
    size_t index;
    for (index = 0; index < sizeof *entry; index++)
        if (bytes[index] != GUARD_BYTE)
            return 0;
    return 1;
}

static vpiHandle find_path(int count)
{
    char full_name[128];
    vpiHandle module, iterator, path;

    snprintf(full_name, sizeof full_name, TOP ".p%d", count);
    module = vpi_handle_by_name((PLI_BYTE8 *)full_name, NULL);
    if (module == NULL)
        return NULL;
    iterator = vpi_iterate(vpiModPath, module);
    if (iterator == NULL)
        return NULL;
    path = vpi_scan(iterator);
    if (path != NULL)
        vpi_release_handle(iterator);
    return path;
}

static void read_case(vpiHandle path, int count, int mtm, int pulse)
{
    int per_delay = mtm && pulse ? 9 : mtm || pulse ? 3 : 1;
    int required = count * per_delay;
    s_vpi_time *storage;
    s_vpi_delay request;
    int index, guards;

    storage = (s_vpi_time *)malloc((size_t)(required + 2) * sizeof *storage);
    if (storage == NULL) {
        vpi_printf((PLI_BYTE8 *)"delay buffer allocation failed\n");
        return;
    }
    memset(storage, GUARD_BYTE, (size_t)(required + 2) * sizeof *storage);
    memset(&request, 0, sizeof request);
    request.da = storage + 1;
    request.no_of_delays = count;
    request.time_type = vpiScaledRealTime;
    request.mtm_flag = mtm;
    request.pulsere_flag = pulse;
    vpi_get_delays(path, &request);
    guards = guard_intact(storage) && guard_intact(storage + required + 1);
    vpi_printf((PLI_BYTE8 *)"count=%d mtm=%d pulse=%d elems=%d appbuf=%d guards=%d:",
               count, mtm, pulse, required, request.da == storage + 1, guards);
    for (index = 0; index < required; index++)
        vpi_printf((PLI_BYTE8 *)" %.0f", storage[index + 1].real);
    vpi_printf((PLI_BYTE8 *)"\n");
    free(storage);
}

static PLI_INT32 run_matrix(PLI_BYTE8 *user_data)
{
    static const int counts[5] = {1, 2, 3, 6, 12};
    int test, mtm, pulse;

    (void)user_data;
    for (test = 0; test < 5; test++) {
        vpiHandle path = find_path(counts[test]);
        if (path == NULL) {
            vpi_printf((PLI_BYTE8 *)"path p%d not found\n", counts[test]);
            continue;
        }
        for (mtm = 0; mtm < 2; mtm++)
            for (pulse = 0; pulse < 2; pulse++)
                read_case(path, counts[test], mtm, pulse);
    }
    return 0;
}

static void register_application(void)
{
    s_vpi_systf_data task;
    memset(&task, 0, sizeof task);
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_delay_matrix";
    task.calltf = run_matrix;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_application, 0};

#ifdef __cplusplus
}
#endif
