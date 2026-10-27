/* VPI application of test_37_extra_name_lookup (IEEE 1800-2023 37.10). */
#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_37_extra_name_lookup"

static vpiHandle by_name(const char *name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
}

/* The variable of a package or of the compilation unit whose full name is
   the one given, found by scanning the package scopes of the design. The
   compilation-unit scope is a scope that holds objects (37.10 makes a package
   an instance and 37.12 gives the variables of a scope); this tool exposes it
   as a package whose objects have a full name that begins with "$unit::"
   (37.10 detail 5). */
static vpiHandle package_variable(const char *full_name)
{
    vpiHandle packages = vpi_iterate(vpiPackage, NULL);
    vpiHandle package;

    while (packages != NULL && (package = vpi_scan(packages)) != NULL) {
        vpiHandle variables = vpi_iterate(vpiVariables, package);
        vpiHandle variable;

        while (variables != NULL && (variable = vpi_scan(variables)) != NULL)
            if (strcmp(vpi_get_str(vpiFullName, variable), full_name) == 0)
                return variable;
    }
    return NULL;
}

/* Whether vpi_handle_by_name finds the name, printed with the name. */
static void lookup(const char *what, const char *name)
{
    vpi_printf((PLI_BYTE8 *)"%s %s: %d\n", what, name, by_name(name) != NULL);
}

/* The full name of an object that exists but that a name lookup must not
   reach, or "missing" if the application could not find the object at all. */
static void exists(const char *what, const char *full_name)
{
    vpiHandle h = package_variable(full_name);

    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: missing\n", what);
    else
        vpi_printf((PLI_BYTE8 *)"%s: %s\n", what, vpi_get_str(vpiFullName, h));
}

static PLI_INT32 lookup_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    exists("imported item", "test_37_extra_name_lookup_pkg::imported_item");
    exists("compilation-unit object", "$unit::unit_item");
    lookup("local variable", TOP ".local_var");
    lookup("imported item in the importing scope", TOP ".imported_item");
    lookup("imported item from the top", "imported_item");
    lookup("compilation-unit object by its name", "unit_item");
    lookup("compilation-unit object in the module", TOP ".unit_item");
    lookup("compilation-unit object by its full name", "$unit::unit_item");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_lookup";
    d.calltf = lookup_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
