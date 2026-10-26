#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void change_inputs(int i, svBitVecVal *v, svLogicVecVal *l, int *o) {
  i = 99;
  v[0] = 0xFF;
  l[0].aval = 0;
  l[0].bval = 0;
  *o = i;
}

#ifdef __cplusplus
}
#endif
