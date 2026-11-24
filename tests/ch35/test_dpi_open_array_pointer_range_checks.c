#include <stddef.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_check_1d(const svOpenArrayHandle source)
{
    const int *value = (const int *)svGetArrElemPtr1(source, 3);

    return value != NULL && *value == 23
        && svGetArrElemPtr1(source, 1) == NULL
        && svGetArrElemPtr1(source, 5) == NULL;
}

int c_check_2d(const svOpenArrayHandle source)
{
    const int *value = (const int *)svGetArrElemPtr2(source, 8, -2);

    return value != NULL && *value == 71
        && svGetArrElemPtr2(source, 6, -2) == NULL
        && svGetArrElemPtr2(source, 9, -2) == NULL
        && svGetArrElemPtr2(source, 8, -4) == NULL
        && svGetArrElemPtr2(source, 8, 0) == NULL;
}

#ifdef __cplusplus
}
#endif
