/* VPI application of test_vpi_statement_control_kinds (IEEE 1800-2023 37.55 to 37.78). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_statement_control_kinds"
#define MAX 16

struct name {
    PLI_INT32 code;
    const char *text;
};

static const struct name names[] = {
    {vpiImmediateAssert, "immediate assert"},
    {vpiImmediateAssume, "immediate assume"},
    {vpiImmediateCover, "immediate cover"},
    {vpiEventStmt, "event"},
    {vpiWhile, "while"},
    {vpiRepeat, "repeat"},
    {vpiWait, "wait"},
    {vpiForever, "forever"},
    {vpiIf, "if"},
    {vpiIfElse, "if"},
    {vpiExpectStmt, "expect"},
    {vpiFor, "for"},
    {vpiDisable, "disable"},
    {vpiReturnStmt, "return"},
    {0, NULL}
};

static const char *name_of(PLI_INT32 code)
{
    static char other[32];
    const struct name *p;

    for (p = names; p->text != NULL; p++)
        if (p->code == code)
            return p->text;
    snprintf(other, sizeof other, "other (%d)", (int)code);
    return other;
}

static int compare(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static PLI_INT32 list_calltf(PLI_BYTE8 *user_data)
{
    char lines[MAX][64];
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".stmts", NULL);
    vpiHandle body = task ? vpi_handle(vpiStmt, task) : NULL, it, s;
    int n = 0, i;

    (void)user_data;
    if (body == NULL) {
        vpi_printf("the body of stmts is missing\n");
        return 0;
    }
    it = vpi_iterate(vpiStmt, body);
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        snprintf(lines[n++], sizeof lines[0], "%s", name_of(vpi_get(vpiType, s)));
    }
    qsort(lines, (size_t)n, sizeof lines[0], compare);
    for (i = 0; i < n; i++)
        vpi_printf("%s\n", lines[i]);
    vpi_printf("statements: %d\n", n);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_list";
    d.calltf = list_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
