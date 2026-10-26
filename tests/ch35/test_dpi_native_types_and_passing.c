#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int native_types(int i, short s, signed char b, const svBitVecVal *u8,
                 const svLogicVecVal *l4, const svBitVecVal *u64, double r,
                 const char *text, svBit flag) {
  int n = i + s + b;
  n += (int)(u8[0] & 0xFF);
  n += (int)(l4[0].aval & 0xF) + (int)(l4[0].bval & 0xF) * 1000;
  n += (int)(u64[0] & 0xFF) + (int)((u64[1] & 0xF) << 8);
  n += (int)(r * 2.0);
  n += (text[0] == 'h') ? 100 : 0;
  n += (text[1] == 'i') ? 10 : 0;
  n += flag;
  return n;
}

void directions(int a, int *o, int *io) {
  *o = a * 10;
  *io = *io + a;
}

#ifdef __cplusplus
}
#endif
