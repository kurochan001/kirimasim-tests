#include <cstdio>

#ifndef ANNEX_J_ABI
#include "dpi_annex_j_versions/dependency.cpp"
#endif

namespace {
struct ClientOffset {
    int value;

    explicit ClientOffset(int version) : value(version * 1000)
    {
#ifdef ANNEX_J_TRACE
        std::printf("client %d initialized\n", version);
#endif
    }
};

#if !defined(ANNEX_J_ABI) || ANNEX_J_ABI == 1
ClientOffset offset_one{1};
#endif
#if !defined(ANNEX_J_ABI) || ANNEX_J_ABI == 2
ClientOffset offset_two{2};
#endif
}

#if !defined(ANNEX_J_ABI) || ANNEX_J_ABI == 1
extern "C" int annex_j_dependency_one();
extern "C" int annex_j_client_one()
{
    return offset_one.value + annex_j_dependency_one();
}
#endif

#if !defined(ANNEX_J_ABI) || ANNEX_J_ABI == 2
extern "C" int annex_j_dependency_two();
extern "C" int annex_j_client_two()
{
    return offset_two.value + annex_j_dependency_two();
}
#endif
