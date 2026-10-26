#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_shared(int a) { return a * 3; }
int c_none(void) { return 7; }
int c_add(int a, int b) { return a + b; }

extern int sv_times(int a, int b);

int call_export(int a, int b) { return sv_times(a, b); }

#ifdef __cplusplus
}
#endif
