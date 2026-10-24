/* C side of test_dpi_export_string_directions (IEEE 1800-2023 H.8.10). */
#include <stdio.h>
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void sv_strings(const char *i, const char **o, const char **io);

void c_run(void)
{
    static char in_text[] = "in";
    static char mine[] = "mine";
    char out_copy[32], inout_copy[32];
    const char *o = NULL;
    const char *io = mine;

    sv_strings(in_text, &o, &io);
    snprintf(out_copy, sizeof out_copy, "%s", o != NULL ? o : "(null)");
    snprintf(inout_copy, sizeof inout_copy, "%s", io != NULL ? io : "(null)");
    printf("c_run: output \"%s\", inout \"%s\", inout pointer changed: %d\n", out_copy,
           inout_copy, io != mine);
    printf("c_run: own buffers still \"%s\" and \"%s\"\n", in_text, mine);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
