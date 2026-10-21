/* C side of test_dpi_context_call_chain (IEEE 1800-2023 35.5.1.3, 35.5.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_down(int n);

static const char *const names[] = {
    "test_dpi_context_call_chain",
    "test_dpi_context_call_chain.a",
    "test_dpi_context_call_chain.b",
};

static int failed_on_entry, failed_after_export;

/* Whether the scope of the chain is another one than want, by their names. */
static int differs(svScope want)
{
    svScope now = svGetScope();
    const char *want_name = want != NULL ? svGetNameFromScope(want) : NULL;
    const char *now_name = now != NULL ? svGetNameFromScope(now) : NULL;

    return want_name == NULL || now_name == NULL || strcmp(want_name, now_name) != 0;
}

/* Calls sv_down of node id (1 for a, 2 for b). */
static int call_node(int id, int n)
{
    svScope target = svGetScopeFromName(names[id]);
    int r;

    svSetScope(target);
    r = sv_down(n);
    failed_after_export += differs(target);
    return r;
}

int c_start(int n)
{
    failed_on_entry += differs(svGetScopeFromName(names[0]));
    return call_node(1, n);
}

int c_down(int id, int n)
{
    failed_on_entry += differs(svGetScopeFromName(names[id]));
    if (n <= 0)
        return 0;
    return call_node(3 - id, n);
}

int c_failed_on_entry(void)
{
    return failed_on_entry;
}

int c_failed_after_export(void)
{
    return failed_after_export;
}

#ifdef __cplusplus
}
#endif
