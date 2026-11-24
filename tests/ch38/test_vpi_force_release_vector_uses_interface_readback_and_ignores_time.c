#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TARGET "test_vpi_force_release_vector_uses_interface_readback_and_ignores_time.bus"

static PLI_INT32 exercise(PLI_BYTE8 *mode)
{
    vpiHandle bus = vpi_handle_by_name(TARGET, NULL);
    if (bus == NULL) {
        vpi_printf("bus handle unavailable\n");
        return 0;
    }
    int release = mode[0] == 'r';
    s_vpi_time ignored = {0};
    ignored.type = vpiSimTime;
    ignored.high = 1;
    ignored.low = 23;
    s_vpi_vecval input[3] = {{0x12345678, 0}, {0x00ff55aa, 0}, {0xd, 0}};
    s_vpi_vecval original[3];
    memcpy(original, input, sizeof input);
    s_vpi_value value = {0};
    value.format = vpiVectorVal;
    value.value.vector = input;
    vpi_put_value(bus, &value, &ignored, release ? vpiReleaseFlag : vpiForceFlag);
    if (!release) return 0;

    const s_vpi_vecval *result = value.value.vector;
    if (result == NULL || value.format != vpiVectorVal) {
        vpi_printf("release vector unavailable\n");
        return 0;
    }
    vpi_printf("release own-buffer=%d input-intact=%d vector=%x_%08x_%08x/%x_%08x_%08x\n",
               result != input, memcmp(input, original, sizeof input) == 0,
               (unsigned)result[2].aval & 0xf, (unsigned)result[1].aval, (unsigned)result[0].aval,
               (unsigned)result[2].bval & 0xf, (unsigned)result[1].bval, (unsigned)result[0].bval);
    return 0;
}

static void register_task(const char *name, const char *mode)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)name;
    task.user_data = (PLI_BYTE8 *)mode;
    task.calltf = exercise;
    vpi_register_systf(&task);
}

static void register_tests(void)
{
    register_task("$vt_vector_force", "force");
    register_task("$vt_vector_release", "release");
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};

#ifdef __cplusplus
}
#endif
