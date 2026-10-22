#include "svdpi.h"
#ifdef __cplusplus
extern "C" {
#endif
extern int sv_value(void);
int c_fetch(void) { return sv_value() + 1; }
#ifdef __cplusplus
}
#endif
