/* VPI application of test_vpi_atomic_task_call_label (IEEE 1800-2023 37.60). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_atomic_task_call_label"
#define MAX 8

static char lines[MAX][96];
static int line_count;

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static const char *kind(PLI_INT32 type)
{
    switch (type) {
    case vpiTaskCall: return "task call";
    case vpiFuncCall: return "func call";
    default: return "other";
    }
}

static PLI_INT32 calls_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".body", NULL);
    vpiHandle body = task != NULL ? vpi_handle(vpiStmt, task) : NULL;
    vpiHandle it = body != NULL ? vpi_iterate(vpiStmt, body) : NULL, s;
    int calls = 0, i;

    (void)user_data;
    while (it != NULL && (s = vpi_scan(it)) != NULL) {
        PLI_INT32 type = vpi_get(vpiType, s);
        const char *name;

        if (type != vpiTaskCall && type != vpiFuncCall)
            continue;
        calls++;
        name = vpi_get_str(vpiName, s);
        if (line_count < MAX)
            snprintf(lines[line_count++], sizeof lines[0], "%s, name %s", kind(type),
                     name != NULL ? name : "NULL");
    }
    qsort(lines, (size_t)line_count, sizeof lines[0], by_text);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    vpi_printf((PLI_BYTE8 *)"task/function calls: %d\n", calls);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_calls";
    d.calltf = calls_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
