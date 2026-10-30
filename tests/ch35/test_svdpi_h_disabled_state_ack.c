/* C side of test_svdpi_h_disabled_state_ack (IEEE 1800-2023 I.3, 35.9, H.9.3). */
#include "svdpi.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_wait(void);

/* An imported task is an int function in C (35.5.4); its result is 1 when it
   returns because of a disable and 0 otherwise (35.9). */
int c_work(void)
{
    int before = svIsDisabledState();
    int returned;
    int disabled;

    printf("before the export: svIsDisabledState gives %d\n", before);
    returned = sv_wait();
    printf("the export returned %d: svIsDisabledState gives %d\n", returned,
           svIsDisabledState());
    disabled = svIsDisabledState();
    if (disabled)
        svAckDisabledState();
    printf("the import acknowledged the disable and returns\n");
    fflush(stdout);
    return disabled ? 1 : 0;
}

#ifdef __cplusplus
}
#endif
