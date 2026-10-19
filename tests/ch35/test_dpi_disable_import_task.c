/* C side of test_dpi_disable_import_task (IEEE 1800-2023 35.9). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_tick(int i);

int dpi_tick_loop(int n)
{
    for (int i = 1; i <= n; i++) {
        if (sv_tick(i) != 0) {
            printf("disabled during tick %d, svIsDisabledState() = %d\n", i, svIsDisabledState());
            fflush(stdout);
            return 1;
        }
    }
    return 0;
}

#ifdef __cplusplus
}
#endif
