/* C side of test_dpi_caller_info (IEEE 1800-2023 H.9.3). */
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static const char unset_name[] = "unset";

static int ends_with(const char *s, const char *tail)
{
    size_t n = strlen(s), m = strlen(tail);
    return n >= m && strcmp(s + n - m, tail) == 0;
}

int c_where(int line)
{
    const char *file = unset_name;
    int number = -12345;
    int known = svGetCallerInfo(&file, &number);

    if (known)
        return file != NULL && ends_with(file, "test_dpi_caller_info.sv") && number == line;
    return file == unset_name && number == -12345;
}

#ifdef __cplusplus
}
#endif
