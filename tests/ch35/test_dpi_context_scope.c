/* C side of test_dpi_context_scope (IEEE 1800-2023 H.9.3). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int unit_id(void);

static int key;

const char *dpi_where(void) { return svGetNameFromScope(svGetScope()); }

void dpi_remember(int v)
{
    int *p = (int *)malloc(sizeof *p);
    *p = v;
    svPutUserData(svGetScope(), &key, p);
}

int dpi_recall(void) { return *(int *)svGetUserData(svGetScope(), &key); }

int dpi_id_of(const char *scope)
{
    svScope old = svSetScope(svGetScopeFromName(scope));
    int id = unit_id();
    svSetScope(old);
    return id;
}

#ifdef __cplusplus
}
#endif
