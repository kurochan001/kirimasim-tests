/* C side of test_dpi_unsigned_types (IEEE 1800-2023 35.5.6, H.7.4). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

unsigned char dpi_inc_ubyte(unsigned char b) { return (unsigned char)(b + 1); }
unsigned short dpi_half_ushort(unsigned short s) { return (unsigned short)(s / 2); }
unsigned int dpi_max_uint(void) { return 0xFFFFFFFFu; }
unsigned long long dpi_pow63(void) { return 1ULL << 63; }
int dpi_color_code(char c) { return 10 * c; }

#ifdef __cplusplus
}
#endif
