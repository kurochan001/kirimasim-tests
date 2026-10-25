/* C side of test_dpi_scope_time_unit_precision (IEEE 1800-2023 H.13). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_times(const char *who)
{
    svScope scope = svGetScope();
    svTimeVal t;
    s_vpi_time *same = &t; /* svTimeVal is the type s_vpi_time */
    int32_t unit = 99, precision = 99, null_unit = 99, null_precision = 99;
    int failed = 0;

    failed |= svGetTimeUnit(scope, &unit) != 0;
    failed |= svGetTimePrecision(scope, &precision) != 0;
    failed |= svGetTimeUnit(NULL, &null_unit) != 0;
    failed |= svGetTimePrecision(NULL, &null_precision) != 0;
    printf("%s: unit %d precision %d; null scope: unit %d precision %d\n", who, (int)unit,
           (int)precision, (int)null_unit, (int)null_precision);

    same->type = vpiScaledRealTime;
    same->real = -1.0;
    failed |= svGetTime(scope, &t) != 0;
    printf("%s: scaled real time in its unit %.3f\n", who, t.real);

    t.type = vpiSimTime;
    t.high = t.low = 0xffffffffu;
    failed |= svGetTime(NULL, &t) != 0;
    printf("%s: null scope simulation time high %u low %u\n", who, (unsigned)t.high,
           (unsigned)t.low);

    t.type = vpiScaledRealTime;
    t.real = -1.0;
    failed |= svGetTime(NULL, same) != 0;
    printf("%s: null scope scaled real time %.1f\n", who, t.real);
    printf("%s: every call returned 0: %d\n", who, !failed);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
