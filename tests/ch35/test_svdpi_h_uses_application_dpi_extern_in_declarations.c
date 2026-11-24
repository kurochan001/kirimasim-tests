/* The sentinel is only declared before its use if the header expands DPI_EXTERN. */
#define DPI_EXTERN extern int application_qualifier_seen;
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int check_application_dpi_qualifier(void)
{
    svBitVecVal word = 0;
    svPutBitselBit(&word, 12, sv_1);
    return application_qualifier_seen == 23 && word == (1u << 12);
}

#ifdef __cplusplus
}
#endif

int application_qualifier_seen = 23;
