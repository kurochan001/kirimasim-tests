#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_tick_task(svBit use_ordinary, int tag);
extern int sv_reentry(int tag);

int enter_sv_task(svBit use_ordinary, int tag)
{
    return sv_tick_task(use_ordinary, tag);
}

int child_context(int tag)
{
    return sv_reentry(tag);
}

int child_ordinary(int tag)
{
    return sv_reentry(tag);
}

#ifdef __cplusplus
}
#endif
