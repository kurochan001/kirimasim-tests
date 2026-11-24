#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 check_arguments(p_cb_data data)
{
    s_vpi_vlog_info info = {0};
    int first = -1, last = -1, empty = -1, repeats = 0;
    int valid_entries, executable;
    (void)data;

    if (!vpi_get_vlog_info(&info) || info.argc < 1 || info.argv == NULL) {
        vpi_printf("missing invocation arguments\n");
        return 0;
    }
    valid_entries = 1;
    executable = info.argv[0] != NULL && info.argv[0][0] != '\0';
    for (int i = 1; i < info.argc; ++i) {
        const char *arg = info.argv[i];
        if (arg == NULL) {
            valid_entries = 0;
        } else if (strcmp(arg, "+vt_level=alpha") == 0) {
            if (first < 0)
                first = i;
            last = i;
            ++repeats;
        } else if (strcmp(arg, "+vt_empty=") == 0) {
            empty = i;
        }
    }
    vpi_printf("argv0=%d entries=%d repetitions=%d ordered=%d\n",
               executable, valid_entries, repeats, first > 0 && first < empty && empty < last);
    return 0;
}

static void register_check(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = check_arguments;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_check, NULL};

#ifdef __cplusplus
}
#endif
