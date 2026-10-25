/* C side of test_svdpi_h_caller_info (IEEE 1800-2023 I.3, H.9.3). */
#include "svdpi.h"
#include <stdio.h>
#include <string.h>

/* The line of the call c_caller() in test_svdpi_h_caller_info.sv. */
#define CALL_LINE 33

#ifdef __cplusplus
extern "C" {
#endif

void c_caller(void)
{
    const char *file = "no file";
    int line = -1;
    int got = svGetCallerInfo(&file, &line);
    int ok;

    if (got)
        ok = file != NULL && strstr(file, "test_svdpi_h_caller_info.sv") != NULL &&
             line == CALL_LINE;
    else
        ok = file != NULL && strcmp(file, "no file") == 0 && line == -1;
    printf("svGetCallerInfo returns 0 or 1 %d\n", got == 0 || got == 1);
    printf("the outputs follow the answer %d\n", ok);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
