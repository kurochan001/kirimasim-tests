/* C side of test_svdpi_h_user_data (IEEE 1800-2023 I.3, H.9.3). */
#include "svdpi.h"
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

static int used_key, unused_key, failed_key;

void c_data(int value)
{
    svScope scope = svGetScope();
    int *stored = (int *)malloc(sizeof *stored);

    *stored = value;
    printf("svPutUserData returns %d\n", svPutUserData(scope, &used_key, stored));
    printf("the same key gives back %d\n", *(int *)svGetUserData(scope, &used_key));
    printf("a key that was never stored gives NULL %d\n",
           svGetUserData(scope, &unused_key) == NULL);
    printf("svPutUserData with a NULL scope returns %d\n",
           svPutUserData(NULL, &failed_key, stored));
    printf("svPutUserData with a NULL data pointer returns %d\n",
           svPutUserData(scope, &failed_key, NULL));
    printf("the key of the failed calls was never stored %d\n",
           svGetUserData(scope, &failed_key) == NULL);
    printf("svGetUserData with a NULL scope gives NULL %d\n",
           svGetUserData(NULL, &used_key) == NULL);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
