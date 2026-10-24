/* VPI application of test_vpi_instance_assertion_members (IEEE 1800-2023 37.49, 37.54). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_instance_assertion_members"

/* counts[0] for the property instance, counts[1] for the sequence instance */
static int counts[2][3];
static const char *const labels[2] = {"property instance p_a", "sequence instance s_ab"};

static const char *name_of(vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "(none)";
}

static const char *base_name(const char *path)
{
    const char *slash = path != NULL ? strrchr(path, '/') : NULL;
    return slash != NULL ? slash + 1 : (path != NULL ? path : "(none)");
}

/* The instance held by an assertion: its vpiProperty, or the property
 * expression of the property spec that vpiProperty gives. */
static vpiHandle instance_of(const char *assertion, vpiHandle *as)
{
    char full[96];
    vpiHandle p;

    snprintf(full, sizeof full, "%s.%s", TOP, assertion);
    *as = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    p = *as != NULL ? vpi_handle(vpiProperty, *as) : NULL;
    if (p != NULL && vpi_get(vpiType, p) == vpiPropertySpec)
        p = vpi_handle(vpiPropertyExpr, p);
    return p;
}

static PLI_INT32 on_assertion(PLI_INT32 reason, p_vpi_time cb_time, vpiHandle assertion,
                              p_vpi_attempt_info info, PLI_BYTE8 *user_data)
{
    int which = (int)(user_data - (PLI_BYTE8 *)labels);

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

static void member(int which, const char *assertion, PLI_INT32 type)
{
    static const PLI_INT32 reasons[3] = {cbAssertionStart, cbAssertionSuccess,
                                         cbAssertionFailure};
    vpiHandle as, inst = instance_of(assertion, &as), m;
    char file[256], decl[32];
    int r;

    if (inst == NULL || vpi_get(vpiType, inst) != type) {
        vpi_printf((PLI_BYTE8 *)"%s: no %s\n", assertion, labels[which]);
        return;
    }
    /* vpi_get_str can reuse its buffer, so each string is copied first. */
    snprintf(file, sizeof file, "%s", vpi_get_str(vpiFile, inst) != NULL
             ? vpi_get_str(vpiFile, inst) : "(none)");
    snprintf(decl, sizeof decl, "%s",
             name_of(vpi_handle(type == vpiPropertyInst ? vpiPropertyDecl : vpiSequenceDecl,
                                inst)));
    m = vpi_handle(vpiInstance, inst);
    vpi_printf((PLI_BYTE8 *)"%s in %s: declaration %s, file %s, start line of %s %d, "
                            "instance %s\n", labels[which], assertion, decl,
               base_name(file), assertion,
               vpi_get(vpiStartLine, inst) == vpi_get(vpiStartLine, as),
               m != NULL && vpi_get_str(vpiFullName, m) != NULL ? vpi_get_str(vpiFullName, m)
               : "NULL");
    for (r = 0; r < 3; r++)
        vpi_register_assertion_cb(inst, reasons[r], on_assertion, (PLI_BYTE8 *)labels + which);
}

static void operand_instance(void)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), it, d, found = NULL, e, op;

    it = top != NULL ? vpi_iterate(vpiSequenceDecl, top) : NULL;
    while (it != NULL && (d = vpi_scan(it)) != NULL)
        if (strcmp(name_of(d), "s_use") == 0)
            found = d;
    e = found != NULL ? vpi_handle(vpiExpr, found) : NULL;
    it = e != NULL ? vpi_iterate(vpiOperand, e) : NULL;
    op = it != NULL ? vpi_scan(it) : NULL;
    if (op != NULL)
        vpi_free_object(it);
    vpi_printf((PLI_BYTE8 *)"s_use: first operand of ## is a sequence instance %d, of %s\n",
               op != NULL && vpi_get(vpiType, op) == vpiSequenceInst,
               op != NULL ? name_of(vpi_handle(vpiSequenceDecl, op)) : "(none)");
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    member(0, "a_pi", vpiPropertyInst);
    member(1, "c_si", vpiSequenceInst);
    operand_instance();
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    for (i = 0; i < 2; i++)
        vpi_printf((PLI_BYTE8 *)"%s callbacks: start %d, success %d, failure %d\n", labels[i],
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
    add_task("$vt_watch", watch_calltf);
    add_task("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
