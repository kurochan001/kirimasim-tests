/* C side of test_dpi_import_task_reentrant_wait (IEEE 1800-2023 35.5.1.5). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int active;

extern int sv_wait_level(int n);
extern int sv_wait_event(void);
extern void sv_back(int id, int active, int own);

int c_visit(int id)
{
    int own = id * 11;
    int disabled;

    active++;
    disabled = id < 3 ? sv_wait_level(id) : sv_wait_event();
    if (!disabled)
        sv_back(id, active, own);
    active--;
    return disabled;
}

#ifdef __cplusplus
}
#endif
