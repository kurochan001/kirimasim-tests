#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_bridge_nested(int tag, svBit use_task);
extern int sv_function_nested(int tag);
extern int sv_task_nested(int tag);

int first_entry(int tag, svBit use_task)
{
    return sv_bridge_nested(tag, use_task);
}

int second_entry(int tag, svBit use_task)
{
    return use_task ? sv_task_nested(tag) : sv_function_nested(tag);
}

#ifdef __cplusplus
}
#endif
