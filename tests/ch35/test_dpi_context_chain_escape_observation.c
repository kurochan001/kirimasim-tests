#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int exported_step(int jump_now);
static jmp_buf landing;
static svScope original, alternate;

void capture_alternate_scope(void)
{
    alternate = svGetScope();
}

int start_chain(int jump_now)
{
    original = svGetScope();
    printf("entered distinct scopes=%d\n", original != NULL && alternate != NULL && original != alternate);
    fflush(stdout);
    if (setjmp(landing) != 0) {
        puts("C landing reached");
        fflush(stdout);
        /* End the observation at the landing point in the C application. */
        _Exit(77);
    }

    int value = exported_step(jump_now);
    printf("C normal value=%d scope restored=%d\n", value, svGetScope() == original);
    fflush(stdout);
    return value + 1;
}

void nested_chain(int jump_now)
{
    printf("nested C scope=%d\n", svGetScope() == original);
    if (alternate != NULL)
        svSetScope(alternate);
    printf("nested scope selected=%d\n", alternate != NULL && svGetScope() == alternate);
    fflush(stdout);
    if (jump_now)
        longjmp(landing, 1);
}

#ifdef __cplusplus
}
#endif
