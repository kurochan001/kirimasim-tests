/* C side of test_svdpi_h_scope_selection (IEEE 1800-2023 I.3, H.9.3). */
#include "svdpi.h"
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int unit_tag(void);

#define TOP "test_svdpi_h_scope_selection"

void c_here(const char *who)
{
    printf("%s: svGetScope names %s, its export answers %d\n", who,
           svGetNameFromScope(svGetScope()), unit_tag());
    fflush(stdout);
}

void c_lookups(void)
{
    svScope top = svGetScope();
    svScope s7 = svGetScopeFromName(TOP ".u7");
    svScope s9 = svGetScopeFromName(TOP ".u9");
    svScope none = svGetScopeFromName(TOP ".unknown");
    svScope previous;

    printf("the top module calls from the scope %s\n", svGetNameFromScope(top));
    printf("lookup gives %s and %s\n", s7 != NULL ? svGetNameFromScope(s7) : "NULL",
           s9 != NULL ? svGetNameFromScope(s9) : "NULL");
    printf("lookup of an unknown name gives NULL %d\n", none == NULL);

    previous = svSetScope(s9);
    printf("svSetScope returns the previous scope %d, is now %s\n", previous == top,
           svGetNameFromScope(svGetScope()));
    printf("the export answers %d in the selected scope\n", unit_tag());
    previous = svSetScope(s7);
    printf("the export answers %d after selecting the other instance\n", unit_tag());
    svSetScope(top);
    printf("back in %s\n", svGetNameFromScope(svGetScope()));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
