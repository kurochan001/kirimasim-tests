/* C side of test_dpi_declaration_scope_kinds (IEEE 1800-2023 H.9.2). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_unit_x2(int v);
extern int sv_pkg_x3(int v);
extern int sv_mod_x4(int v);
extern int sv_ifc_x5(int v);
extern int sv_prg_x6(int v);
extern int sv_gen_x7(int v);

int c_unit_add(int a, int b) { return a + b; }
int c_unit_call(int v) { return sv_unit_x2(v) + 1; }
int c_pkg_add(int a, int b) { return a + b; }
int c_pkg_call(int v) { return sv_pkg_x3(v) + 1; }
int c_mod_add(int a, int b) { return a + b; }
int c_mod_call(int v) { return sv_mod_x4(v) + 1; }
int c_ifc_add(int a, int b) { return a + b; }
int c_ifc_call(int v) { return sv_ifc_x5(v) + 1; }
int c_prg_add(int a, int b) { return a + b; }
int c_prg_call(int v) { return sv_prg_x6(v) + 1; }
int c_gen_add(int a, int b) { return a + b; }
int c_gen_call(int v) { return sv_gen_x7(v) + 1; }

#ifdef __cplusplus
}
#endif
