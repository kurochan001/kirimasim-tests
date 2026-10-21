/* VPI application of test_vpi_systf_in_program_and_final (36.4, 9.2.3). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 program_note(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("system task in program\n");
    return 0;
}

static PLI_INT32 final_note(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("system task in final\n");
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_program_note", program_note);
    add("$vt_final_note", final_note);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
