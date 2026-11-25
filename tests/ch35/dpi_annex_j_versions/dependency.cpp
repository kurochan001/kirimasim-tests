#include <cstdio>

namespace {
struct DependencyState {
    int value;

    explicit DependencyState(int version) : value(version * 100)
    {
#ifdef ANNEX_J_TRACE
        std::printf("dependency %d initialized\n", version);
#endif
    }
};

#if !defined(ANNEX_J_ABI) || ANNEX_J_ABI == 1
DependencyState state_one{1};
#endif
#if !defined(ANNEX_J_ABI) || ANNEX_J_ABI == 2
DependencyState state_two{2};
#endif
}

#if !defined(ANNEX_J_ABI) || ANNEX_J_ABI == 1
extern "C" int annex_j_dependency_one()
{
    return state_one.value + 17;
}
#endif

#if !defined(ANNEX_J_ABI) || ANNEX_J_ABI == 2
extern "C" int annex_j_dependency_two()
{
    return state_two.value + 31;
}
#endif
