/* C side of test_dpi_unpacked_struct (IEEE 1800-2023 35.5.6, H.7.8). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    int count;
    char code;
    double scale;
} item_t;

double dpi_total(const item_t *it) { return (it->count + it->code) * it->scale; }

void dpi_make(int n, item_t *it)
{
    it->count = n;
    it->code = (char)(-n);
    it->scale = n / 8.0;
}

#ifdef __cplusplus
}
#endif
