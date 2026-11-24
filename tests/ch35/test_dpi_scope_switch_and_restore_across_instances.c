#include <stddef.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int instance_id(void);

int c_probe_scope(svBit save)
{
    static svScope first;
    svScope current = svGetScope();
    int before, switched, restored;

    if (current == NULL)
        return -1;
    before = instance_id();
    if (save) {
        if (first != NULL && first != current)
            return -2;
        first = current;
        return before;
    }
    if (first == NULL || first == current)
        return -3;
    if (svSetScope(first) != current || svGetScope() != first)
        return -4;
    switched = instance_id();
    if (svSetScope(current) != first || svGetScope() != current)
        return -5;
    restored = instance_id();
    return 100 * before + 10 * switched + restored;
}

#ifdef __cplusplus
}
#endif
