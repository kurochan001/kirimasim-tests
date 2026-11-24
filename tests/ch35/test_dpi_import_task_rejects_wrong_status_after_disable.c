#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int waiter_from_c(int wait_units);
extern int forbidden_export(void);

int observed_import(int mode)
{
    int asynchronous_disable = mode == 0 || mode == 2 || mode == 3;
    int exported_status = waiter_from_c(asynchronous_disable ? 10 : 2);
    int disabled = svIsDisabledState();
    printf("export status=%d disabled=%d\n", exported_status, disabled);
    fflush(stdout);

    switch (mode) {
    case 0:
        return 0;  /* Wrong after disable. */
    case 1:
        return 1;  /* Wrong after normal completion. */
    case 2:
        puts("attempting a second export in the disabled state");
        fflush(stdout);
        (void)forbidden_export();
        return 1;
    default:
        return exported_status;
    }
}

#ifdef __cplusplus
}
#endif
