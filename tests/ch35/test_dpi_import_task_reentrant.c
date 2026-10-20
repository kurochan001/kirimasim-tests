/* C side of test_dpi_import_task_reentrant (IEEE 1800-2023 35.5.1.5). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int active, most;

extern int sv_wait(int d);
extern void sv_report(int id, int local_value);

int c_waiter(int id, int d)
{
    int local_value = id * 100;

    if (++active > most)
        most = active;
    if (sv_wait(d) != 0) {
        active--;
        return 1;
    }
    sv_report(id, local_value);
    active--;
    return 0;
}

int c_max_active(void)
{
    return most;
}

#ifdef __cplusplus
}
#endif
