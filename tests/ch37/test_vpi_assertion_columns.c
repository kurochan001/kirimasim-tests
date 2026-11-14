/* VPI application of test_vpi_assertion_columns (IEEE 1800-2023 37.49, 39.3.2). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_columns"

struct where {
    int found;
    int start_line, end_line;
    int column, end_column;
};

static struct where locate(const char *name)
{
    char full[96];
    vpiHandle h;
    struct where w;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    w.found = h != NULL;
    w.start_line = h != NULL ? (int)vpi_get(vpiStartLine, h) : 0;
    w.end_line = h != NULL ? (int)vpi_get(vpiEndLine, h) : 0;
    w.column = h != NULL ? (int)vpi_get(vpiColumn, h) : 0;
    w.end_column = h != NULL ? (int)vpi_get(vpiEndColumn, h) : 0;
    return w;
}

static void compare(const char *later, const char *earlier, const char *how,
                    struct where l, struct where e)
{
    vpi_printf((PLI_BYTE8 *)"%s against %s, %s: start column %+d, end column %+d\n",
               later, earlier, how, l.column - e.column, l.end_column - e.end_column);
}

static PLI_INT32 columns_calltf(PLI_BYTE8 *user_data)
{
    struct where c1 = locate("c1"), c2 = locate("c2"), c3 = locate("c3");
    struct where c4 = locate("c4"), c5 = locate("c5");

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"assertions found by name: %d of 5\n",
               c1.found + c2.found + c3.found + c4.found + c5.found);
    vpi_printf((PLI_BYTE8 *)"c1: on one line %d, end column after start column %d\n",
               c1.found && c1.start_line == c1.end_line, c1.end_column > c1.column);
    compare("c2", "c1", "3 more spaces before it", c2, c1);
    compare("c3", "c1", "6 more characters inside it", c3, c1);
    compare("c5", "c4", "40 characters later on the same line", c5, c4);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_columns";
    d.calltf = columns_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
