/* C side of test_svdpi_h_scope_time (IEEE 1800-2023 I.3, H.13, 3.14.3, 38.13). */
#include "svdpi.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

void c_times(const char *who)
{
    svScope scope = svGetScope();
    svTimeVal t;
    int32_t unit = 0, precision = 0, null_unit = 0, null_precision = 0;
    int failed = 0;

    failed |= svGetTimeUnit(scope, &unit) != 0;
    failed |= svGetTimePrecision(scope, &precision) != 0;
    failed |= svGetTimeUnit(NULL, &null_unit) != 0;
    failed |= svGetTimePrecision(NULL, &null_precision) != 0;
    printf("%s: unit %d precision %d, for a NULL scope %d %d\n", who, (int)unit,
           (int)precision, (int)null_unit, (int)null_precision);

    t.type = vpiScaledRealTime;
    t.real = -1.0;
    failed |= svGetTime(scope, &t) != 0;
    printf("%s: scaled real time in its unit %.3f\n", who, t.real);

    t.type = vpiSimTime;
    t.high = t.low = 0xffffffffu;
    failed |= svGetTime(NULL, &t) != 0;
    printf("%s: simulation time high %u low %u\n", who, (unsigned)t.high, (unsigned)t.low);
    printf("%s: every call returned 0 %d\n", who, !failed);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
