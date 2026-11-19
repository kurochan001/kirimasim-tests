/* C side of test_svdpi_h_signed_bits_macro_tokens (IEEE 1800-2023 I.3, H.10.1.2). */
#include "svdpi.h"
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Keep SV_MASK(N) unexpanded in the text of SV_GET_SIGNED_BITS. */
#undef SV_MASK
#define VT_STR(x) #x
#define VT_XSTR(x) VT_STR(x)

static const char vt_text[] = VT_XSTR(SV_GET_SIGNED_BITS(v, n));

int dpi_signed_bits_text(void)
{
    static const char want[] =
        "((n)==32?(v):(((v)&(1<<(n)))?((v)|~SV_MASK(n)):((v)&SV_MASK(n))))";
    char got[sizeof vt_text];
    size_t k = 0, i;

    for (i = 0; vt_text[i] != '\0'; i++)
        if (vt_text[i] != ' ')
            got[k++] = vt_text[i];
    got[k] = '\0';
    printf("SV_GET_SIGNED_BITS(v, n) tokens: %s\n", got);
    fflush(stdout);
    return strcmp(got, want) == 0;
}

#ifdef __cplusplus
}
#endif
