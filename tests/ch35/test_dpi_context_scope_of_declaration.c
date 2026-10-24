/* C side of test_dpi_context_scope_of_declaration (IEEE 1800-2023 H.9.2, H.9.3). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int unit_id(void);
extern int gen_id(void);

static const char *where(void)
{
    svScope s = svGetScope();
    return s != NULL ? svGetNameFromScope(s) : "NULL";
}

const char *c_where(void) { return where(); }
const char *c_where_ifc(void) { return where(); }
const char *c_where_gen(void) { return where(); }

int c_whoami(void) { return unit_id(); }

void c_lookup_gen(void)
{
    static const char *const names[] = {"test_dpi_context_scope_of_declaration.gb[0]",
                                        "test_dpi_context_scope_of_declaration.gb[1]"};
    svScope here = svGetScope();
    int k;

    for (k = 0; k < 2; k++) {
        svScope s = svGetScopeFromName(names[k]);
        printf("lookup of %s: %s", names[k], s != NULL ? svGetNameFromScope(s) : "NULL");
        if (s != NULL) {
            svSetScope(s);
            printf(", gen_id %d", gen_id());
        }
        printf("\n");
    }
    svSetScope(here);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
