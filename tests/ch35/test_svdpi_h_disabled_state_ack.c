/* C side of test_svdpi_h_disabled_state_ack (IEEE 1800-2023 I.3, 35.9, H.9.3). */
#include "svdpi.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_wait(void);

void c_work(void)
{
    int before = svIsDisabledState();
    int returned;

    printf("before the export: svIsDisabledState gives %d\n", before);
    returned = sv_wait();
    printf("the export returned %d: svIsDisabledState gives %d\n", returned,
           svIsDisabledState());
    if (svIsDisabledState())
        svAckDisabledState();
    printf("the import acknowledged the disable and returns\n");
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
