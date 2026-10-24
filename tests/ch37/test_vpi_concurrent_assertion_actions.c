/* VPI application of test_vpi_concurrent_assertion_actions (IEEE 1800-2023 37.50). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_concurrent_assertion_actions"

/* counts[0] for m_am, counts[1] for r_rs; start, success, failure */
static int counts[2][3];
static const char *const names[2] = {"m_am", "r_rs"};

static vpiHandle find(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* The left-hand side of an action statement, or NULL. */
static void action(vpiHandle stmt, char *out, size_t len)
{
    vpiHandle lhs;
    PLI_BYTE8 *s;

    if (stmt == NULL) {
        snprintf(out, len, "NULL");
        return;
    }
    lhs = vpi_get(vpiType, stmt) == vpiAssignment ? vpi_handle(vpiLhs, stmt) : NULL;
    s = lhs != NULL ? vpi_get_str(vpiName, lhs) : NULL;
    snprintf(out, len, "assignment to %s", s != NULL ? s : "(not an assignment)");
}

static void actions_of(const char *name, int with_else)
{
    vpiHandle as = find(name);
    char pass[64], fail[64];

    if (as == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s not found\n", name);
        return;
    }
    action(vpi_handle(vpiStmt, as), pass, sizeof pass);
    if (with_else) {
        action(vpi_handle(vpiElseStmt, as), fail, sizeof fail);
        vpi_printf((PLI_BYTE8 *)"%s: pass statement %s, fail statement %s\n", name, pass, fail);
    } else {
        vpi_printf((PLI_BYTE8 *)"%s: pass statement %s\n", name, pass);
    }
}

static PLI_INT32 on_assertion(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                              p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    int which = (int)(user_data - (PLI_BYTE8 *)names);

    (void)cb_time;
    (void)assertion;
    (void)info;
    if (which < 0 || which > 1)
        return 0;
    if (reason == cbAssertionStart)
        counts[which][0]++;
    else if (reason == cbAssertionSuccess)
        counts[which][1]++;
    else if (reason == cbAssertionFailure)
        counts[which][2]++;
    return 0;
}

static PLI_INT32 actions_calltf(PLI_BYTE8 *user_data)
{
    static const PLI_INT32 reasons[3] = {cbAssertionStart, cbAssertionSuccess,
                                         cbAssertionFailure};
    vpiHandle h;
    int i, r;

    (void)user_data;
    actions_of("a_as", 1);
    actions_of("m_am", 1);
    actions_of("c_cv", 0);
    actions_of("r_rs", 1);
    for (i = 0; i < 2; i++) {
        h = find(names[i]);
        if (h == NULL)
            continue;
        for (r = 0; r < 3; r++)
            vpi_register_assertion_cb(h, reasons[r], on_assertion, (PLI_BYTE8 *)names + i);
    }
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    for (i = 0; i < 2; i++)
        vpi_printf((PLI_BYTE8 *)"%s callbacks: start %d, success %d, failure %d\n", names[i],
                   counts[i][0], counts[i][1], counts[i][2]);
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add_task("$vt_actions", actions_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
