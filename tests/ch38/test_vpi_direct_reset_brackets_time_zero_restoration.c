#define RESET_TEST_TOP "test_vpi_direct_reset_brackets_time_zero_restoration"
#include "checkpoint_fixtures/reset_trace.h"

#ifdef __cplusplus
extern "C" {
#endif

void (*vlog_startup_routines[])(void) = {trace_reset, NULL};

#ifdef __cplusplus
}
#endif
