/* C side of test_35_rest_noncontext_export_error (IEEE 1800-2023 35.5.3). */
#include <stdio.h>
#include <unistd.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_add(int v);

int c_nc_chain(int v)
{
    /* The abort message of the simulator is written to standard output. Send
       it to standard error, where the harness reads a diagnostic, so that the
       design's own output stays alone on standard output. */
    fflush(stdout);
    dup2(STDERR_FILENO, STDOUT_FILENO);
    return sv_add(v);
}

#ifdef __cplusplus
}
#endif
