/* C side of test_dpi_export_task_result (IEEE 1800-2023 H.8.2, 35.9). */
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_record(int x);
extern int sv_recorded(void);

void c_call_task(void)
{
    int result = sv_record(77);

    printf("the exported task returned %d\n", result);
    printf("the task stored %d\n", sv_recorded());
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
