#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void sv_task(int a);
extern int sv_alias(int a);
extern short sv_short(short a);

void call_exports(int a) {
  sv_task(a);
  printf("alias=%d short=%d\n", sv_alias(a), (int)sv_short((short)a));
  fflush(stdout);
}

#ifdef __cplusplus
}
#endif
