/* An instrumented library for fixture-owned protect license requests. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int check(const char *feature)
{
    int result = strcmp(feature, "allow") == 0 ? LICENSE_RETURN : 19;

    const char *path = getenv("PROTECT_FIXTURE_LICENSE_TRACE");
    FILE *trace = path ? fopen(path, "a") : NULL;
    if (trace != NULL) {
        fprintf(trace, "entry %s %s %d\n", LICENSE_PHASE, feature, result);
        fclose(trace);
    }
    return result;
}

void done(void)
{
    const char *path = getenv("PROTECT_FIXTURE_LICENSE_TRACE");
    FILE *trace = path ? fopen(path, "a") : NULL;
    if (trace != NULL) {
        fprintf(trace, "release %s\n", LICENSE_PHASE);
        fclose(trace);
    }
}
