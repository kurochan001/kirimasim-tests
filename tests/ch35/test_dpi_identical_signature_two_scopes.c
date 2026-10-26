#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int same_foreign(int a, int b) { return a * 10 + b; }
int identity(int a) { return a; }
int plus_one(int a) { return a + 1; }
int with_context(int a) { return a + 2; }

#ifdef __cplusplus
}
#endif
