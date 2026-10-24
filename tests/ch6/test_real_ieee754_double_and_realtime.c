/* C side of test_real_ieee754_double_and_realtime (IEEE 1800-2023 6.12). */
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

long long rd_bits(double x)
{
    long long b;
    memcpy(&b, &x, sizeof b);
    return b;
}

double rd_from_bits(long long b)
{
    double x;
    memcpy(&x, &b, sizeof x);
    return x;
}

#ifdef __cplusplus
}
#endif
