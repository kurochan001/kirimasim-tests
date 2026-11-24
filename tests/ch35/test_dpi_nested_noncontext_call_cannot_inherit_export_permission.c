#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int br_sv_bridge(svBit forbid_context, int tag);
extern int br_sv_marker(int tag);

int br_enter_chain(svBit forbid_context, int tag)
{
    return br_sv_bridge(forbid_context, tag);
}

int br_context_child(int tag)
{
    return br_sv_marker(tag);
}

int br_noncontext_child(int tag)
{
    return br_sv_marker(tag);
}

#ifdef __cplusplus
}
#endif
