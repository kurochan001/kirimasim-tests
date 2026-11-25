/* IEEE 1800-2023 37.29: inspect the directly named interface expressions. */
#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#define TOP "test_vpi_direct_modport_expression"

static int is_kind(vpiHandle object, PLI_INT32 kind)
{
    return object && vpi_get(vpiType, object) == kind;
}

static int same(vpiHandle left, vpiHandle right)
{
    return left && right && vpi_compare_objects(left, right);
}

static void show(const char *label, vpiHandle rhs, vpiHandle physical,
                 vpiHandle reader, vpiHandle writer)
{
    vpi_printf("%s: interface=%d modport=%d physical=%d reader=%d writer=%d\n",
               label, is_kind(rhs, vpiInterface), is_kind(rhs, vpiModport),
               same(rhs, physical), same(rhs, reader), same(rhs, writer));
}

static PLI_INT32 observe(p_cb_data callback)
{
    vpiHandle physical = vpi_handle_by_name((PLI_BYTE8 *)TOP ".physical", NULL);
    vpiHandle reader = vpi_handle_by_name((PLI_BYTE8 *)TOP ".physical.reader", NULL);
    vpiHandle writer = vpi_handle_by_name((PLI_BYTE8 *)TOP ".physical.writer", NULL);
    vpiHandle task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".bind_views", NULL);
    vpiHandle body = task ? vpi_handle(vpiStmt, task) : NULL;
    vpiHandle iter = body ? vpi_iterate(vpiStmt, body) : NULL;
    vpiHandle stmt, whole_rhs = NULL, view_rhs = NULL;
    int assignments = 0;

    (void)callback;
    while (iter && (stmt = vpi_scan(iter))) {
        vpiHandle lhs;
        const char *name;

        if (!is_kind(stmt, vpiAssignment))
            continue;
        assignments++;
        lhs = vpi_handle(vpiLhs, stmt);
        name = lhs ? vpi_get_str(vpiName, lhs) : NULL;
        if (name && strcmp(name, "whole") == 0)
            whole_rhs = vpi_handle(vpiRhs, stmt);
        else if (name && strcmp(name, "view") == 0)
            view_rhs = vpi_handle(vpiRhs, stmt);
    }

    vpi_printf("controls: physical=%d reader=%d writer=%d distinct=%d assignments=%d\n",
               is_kind(physical, vpiInterface), is_kind(reader, vpiModport),
               is_kind(writer, vpiModport), reader && writer && !same(reader, writer),
               assignments);
    show("whole", whole_rhs, physical, reader, writer);
    show("view", view_rhs, physical, reader, writer);
    return 0;
}

static void register_all(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_all, NULL};
