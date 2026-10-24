/* C side of test_dpi_scope_user_data_and_lookup (IEEE 1800-2023 H.9.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int unit_id(void);
extern int ifc_tag(void);
extern int prg_tag(void);

#define TOP "test_dpi_scope_user_data_and_lookup"

static int shared_key, own_key, common_key;

static int read_key(void *key)
{
    int *p = (int *)svGetUserData(svGetScope(), key);
    return p != NULL ? *p : -1;
}

static int put_key(void *key, int v)
{
    int *p = (int *)malloc(sizeof *p);
    *p = v;
    return svPutUserData(svGetScope(), key, p);
}

int c_get_shared(void) { return read_key(&shared_key); }
int c_put_shared(int v) { return put_key(&shared_key, v); }
int c_read_shared_too(void) { return read_key(&shared_key); }
int c_put_own(int v) { return put_key(&own_key, v); }
int c_get_own(void) { return read_key(&own_key); }
int c_get_common(void) { return read_key(&common_key); }

void c_bump_common(void)
{
    int *p = (int *)svGetUserData(svGetScope(), &common_key);
    if (p != NULL)
        (*p)++;
}

void c_share_common(void)
{
    static int common = 777;
    printf("c_share_common: stored in u1 %d, in u2 %d\n",
           svPutUserData(svGetScopeFromName(TOP ".u1"), &common_key, &common),
           svPutUserData(svGetScopeFromName(TOP ".u2"), &common_key, &common));
    fflush(stdout);
}

void c_lookups(void)
{
    svScope here = svGetScope();
    svScope s;

    s = svGetScopeFromName(TOP ".u2");
    printf("lookup of u2: %s", s != NULL ? svGetNameFromScope(s) : "NULL");
    if (s != NULL) {
        svSetScope(s);
        printf(", unit_id there %d", unit_id());
    }
    s = svGetScopeFromName(TOP ".i1");
    printf("\nlookup of i1: %s", s != NULL ? svGetNameFromScope(s) : "NULL");
    if (s != NULL) {
        svSetScope(s);
        printf(", ifc_tag there %d", ifc_tag());
    }
    s = svGetScopeFromName(TOP ".p1");
    printf("\nlookup of p1: %s", s != NULL ? svGetNameFromScope(s) : "NULL");
    if (s != NULL) {
        svSetScope(s);
        printf(", prg_tag there %d", prg_tag());
    }
    s = svGetScopeFromName(TOP ".no_such_instance");
    printf("\nlookup of no_such_instance: %s\n", s != NULL ? "found" : "NULL");
    svSetScope(here);
    fflush(stdout);
}

void c_set_scope(void)
{
    svScope here = svGetScope();
    svScope u1 = svGetScopeFromName(TOP ".u1");
    svScope u2 = svGetScopeFromName(TOP ".u2");
    svScope prev;
    int id;

    printf("c_set_scope: current scope %s\n", svGetNameFromScope(here));
    prev = svSetScope(u1);
    id = unit_id();
    printf("svSetScope(u1) returns the current scope: %d, unit_id %d\n", prev == here, id);
    prev = svSetScope(u2);
    id = unit_id();
    printf("svSetScope(u2) returns u1: %d, unit_id %d\n", prev == u1, id);
    prev = svSetScope(here);
    printf("svSetScope back returns u2: %d, svGetScope is the first scope: %d\n", prev == u2,
           svGetScope() == here);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
