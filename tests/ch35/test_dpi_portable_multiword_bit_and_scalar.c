#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int portable_words(const svBitVecVal *data, svBitVecVal *rotated, int *calls)
{
    const svBitVecVal top = data[2] & 1u;
    rotated[0] = data[1];
    rotated[1] = data[0];
    rotated[2] = top ^ 1u;
    *calls += 2;
    return (int)top;
}

#ifdef __cplusplus
}
#endif
