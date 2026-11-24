#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int wait_before_return(int tag);
extern int finish_immediately(int tag);

int observe_disable(int tag)
{
    int status = wait_before_return(tag);
    int disabled = svIsDisabledState();
    printf("export status=%d disabled=%d\n", status, disabled);
    puts("attempting second task");
    fflush(stdout);
    (void)finish_immediately(tag);
    return 1;
}

#ifdef __cplusplus
}
#endif
