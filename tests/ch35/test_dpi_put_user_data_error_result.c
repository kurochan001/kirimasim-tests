/* C side of test_dpi_put_user_data_error_result (IEEE 1800-2023 H.9.3). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int key_a, key_b, value = 5;

void c_put_errors(void)
{
    svScope here = svGetScope();
    int *got;

    printf("svPutUserData with NULL user data: %d\n", svPutUserData(here, &key_a, NULL));
    printf("svPutUserData with a NULL scope: %d\n", svPutUserData(NULL, &key_a, &value));
    printf("svGetUserData with the first key afterwards: %s\n",
           svGetUserData(here, &key_a) == NULL ? "NULL" : "not NULL");
    printf("svPutUserData with the scope, another key and data: %d\n",
           svPutUserData(here, &key_b, &value));
    got = (int *)svGetUserData(here, &key_b);
    printf("svGetUserData with that key: %d\n", got != NULL ? *got : -1);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
