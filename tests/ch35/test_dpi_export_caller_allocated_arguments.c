/* C side of test_dpi_export_caller_allocated_arguments (IEEE 1800-2023 H.8.2, H.8.5). */
#include "svdpi.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void sv_fill(svBitVecVal *w, int *n, const svBitVecVal *p);
extern int sv_sum(int a, int b);

void c_call_exports(void)
{
    svBitVecVal words[2];
    svBitVecVal byte;
    int count = 0;

    words[0] = 0xffffffffu;
    words[1] = 0xffffffffu;
    byte = 0x5au;
    sv_fill(words, &count, &byte);
    printf("filled count %d, low word %08x, high word %08x\n", count,
           words[0], words[1]);
    printf("returned sum %d\n", sv_sum(3, 4));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
