#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_seen(int a, const svBitVecVal *b, int c) {
  if (a != 15) return 1;
  if ((b[0] & 0xFFFF) != 0xABCD) return 2;
  if (c != -1) return 3;
  return 0;
}

void c_set(int *v) {
  *v = 9;
}

#ifdef __cplusplus
}
#endif
