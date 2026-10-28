/*
 * fst_read.c - print a deterministic text view of an FST file.
 *
 * This is a test harness helper, not a simulator. It uses the libfst reader
 * from gtkwave/libfst (MIT). Build it with tools/fst_reader.py, which passes
 * the libfst source directory.
 *
 * Usage:
 *   fst_read FILE.fst [TIME ...]
 *
 * With no TIME, the start and end times are sampled. The output is:
 *   start=<n>
 *   end=<n>
 *   scopes=<n>
 *   vars=<n>
 *   timescale=<signed byte>
 *   scope <type> <name>
 *   var <type> <direction> <length> <name>
 *   t=<time> <name>=<value>
 */

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "fstapi.h"

struct var {
    fstHandle handle;
    char *name;
    unsigned length;
    unsigned type;
    unsigned direction;
};

struct scope {
    unsigned type;
    char *name;
};

static int compare_vars(const void *a, const void *b)
{
    const struct var *va = a;
    const struct var *vb = b;
    if (va->handle < vb->handle) return -1;
    if (va->handle > vb->handle) return 1;
    return 0;
}

int main(int argc, char **argv)
{
    fstReaderContext *reader;
    struct fstHier *hier;
    struct var *vars = NULL;
    struct scope *scopes = NULL;
    size_t nvars = 0, capvars = 0;
    size_t nscopes = 0, capscopes = 0;
    uint64_t *times = NULL;
    size_t ntimes = 0;
    unsigned i;

    if (argc < 2) {
        fprintf(stderr, "usage: %s FILE.fst [TIME ...]\n", argv[0]);
        return 2;
    }

    reader = fstReaderOpen(argv[1]);
    if (reader == NULL) {
        fprintf(stderr, "cannot open FST file: %s\n", argv[1]);
        return 2;
    }

    while ((hier = fstReaderIterateHier(reader)) != NULL) {
        if (hier->htyp == FST_HT_SCOPE) {
            if (nscopes == capscopes) {
                capscopes = capscopes ? capscopes * 2 : 8;
                scopes = realloc(scopes, capscopes * sizeof(*scopes));
                if (scopes == NULL) goto nomem;
            }
            scopes[nscopes].type = hier->u.scope.typ;
            scopes[nscopes].name = strdup(hier->u.scope.name ? hier->u.scope.name : "");
            if (scopes[nscopes].name == NULL) goto nomem;
            nscopes++;
        } else if (hier->htyp == FST_HT_VAR) {
            if (nvars == capvars) {
                capvars = capvars ? capvars * 2 : 8;
                vars = realloc(vars, capvars * sizeof(*vars));
                if (vars == NULL) goto nomem;
            }
            vars[nvars].handle = hier->u.var.handle;
            vars[nvars].name = strdup(hier->u.var.name ? hier->u.var.name : "");
            if (vars[nvars].name == NULL) goto nomem;
            vars[nvars].length = hier->u.var.length;
            vars[nvars].type = hier->u.var.typ;
            vars[nvars].direction = hier->u.var.direction;
            nvars++;
        }
    }

    qsort(vars, nvars, sizeof(*vars), compare_vars);

    printf("start=%" PRIu64 "\n", fstReaderGetStartTime(reader));
    printf("end=%" PRIu64 "\n", fstReaderGetEndTime(reader));
    printf("scopes=%" PRIu64 "\n", fstReaderGetScopeCount(reader));
    printf("vars=%" PRIu64 "\n", fstReaderGetVarCount(reader));
    printf("timescale=%d\n", (int)fstReaderGetTimescale(reader));
    for (i = 0; i < nscopes; i++) {
        printf("scope %u %s\n", scopes[i].type, scopes[i].name);
    }
    for (i = 0; i < nvars; i++) {
        printf("var %u %u %u %s\n", vars[i].type, vars[i].direction,
               vars[i].length, vars[i].name);
    }

    if (argc > 2) {
        ntimes = (size_t)(argc - 2);
        times = calloc(ntimes, sizeof(*times));
        if (times == NULL) goto nomem;
        for (i = 0; i < ntimes; i++) {
            times[i] = strtoull(argv[i + 2], NULL, 10);
        }
    } else {
        ntimes = 2;
        times = calloc(ntimes, sizeof(*times));
        if (times == NULL) goto nomem;
        times[0] = fstReaderGetStartTime(reader);
        times[1] = fstReaderGetEndTime(reader);
    }

    for (i = 0; i < ntimes; i++) {
        for (size_t v = 0; v < nvars; v++) {
            size_t size = (size_t)vars[v].length + 1;
            char *buf = calloc(size ? size : 1, 1);
            char *value;
            if (buf == NULL) goto nomem;
            value = fstReaderGetValueFromHandleAtTime(reader, times[i],
                                                      vars[v].handle, buf);
            printf("t=%" PRIu64 " %s=%s\n", times[i], vars[v].name,
                   value ? value : "");
            free(buf);
        }
    }

    for (i = 0; i < nscopes; i++) free(scopes[i].name);
    for (i = 0; i < nvars; i++) free(vars[i].name);
    free(scopes);
    free(vars);
    free(times);
    fstReaderClose(reader);
    return 0;

nomem:
    for (i = 0; i < nscopes; i++) free(scopes[i].name);
    for (i = 0; i < nvars; i++) free(vars[i].name);
    free(scopes);
    free(vars);
    free(times);
    fstReaderClose(reader);
    return 2;
}
