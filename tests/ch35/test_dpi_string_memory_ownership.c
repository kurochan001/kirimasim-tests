/* C side of test_dpi_string_memory_ownership (IEEE 1800-2023 35.5.1.4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static char buffer[32];
static char *made;
static char *kept;

void c_bracket(const char **s)
{
    snprintf(buffer, sizeof buffer, "[%s]", *s);
    *s = buffer;
}

const char *c_make(int n)
{
    free(made);
    made = (char *)malloc(16);
    snprintf(made, 16, "item %d", n);
    return made;
}

void c_drop(void)
{
    if (made != NULL)
        memset(made, '?', strlen(made));
    free(made);
    made = NULL;
}

void c_keep(const char *s)
{
    free(kept);
    kept = (char *)malloc(strlen(s) + 1);
    strcpy(kept, s);
}

const char *c_kept(void)
{
    return kept;
}

#ifdef __cplusplus
}
#endif
