/* C side of test_dpi_import_export_forms (IEEE 1800-2023 35.5.4, 35.7,
   35.8). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_triple(int v);
extern int slink(int v);
extern int sv_bump(int v);

int di_add(int a, int b) { return a + b; }
int di_pure(int a) { return 2 * a; }
int di_ctx(int v) { return sv_triple(v) + slink(v); }
int di_task(int v) { return sv_bump(v); }
int dlink(int a) { return a + 100; }
int di_flat(void) { return 42; }

#ifdef __cplusplus
}
#endif
