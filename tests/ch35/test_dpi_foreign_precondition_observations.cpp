#include <cstdio>
#include "svdpi.h"

extern "C" int exported_value(int a);
static int pure_counter;

extern "C" void input_view(const svBitVecVal *value)
{
#ifdef DPI_ALTER_INPUT
    std::puts("C input write requested");
    std::fflush(stdout);
    auto *writable = const_cast<svBitVecVal *>(value);
    writable[0] ^= 0x20u;
    std::printf("C altered input low=%08x\n", static_cast<unsigned>(writable[0]));
#else
    std::printf("C input low=%08x\n", static_cast<unsigned>(value[0]));
#endif
    std::fflush(stdout);
}

extern "C" int pure_value(int value)
{
#ifdef DPI_ALTER_PURE
    ++pure_counter;
    std::puts("C pure state changed");
    std::fflush(stdout);
    return value * 3 + pure_counter;
#else
    return value * 3;
#endif
}

extern "C" int read_pure_counter()
{
    return pure_counter;
}

extern "C" int ordinary(int value)
{
#ifdef DPI_ALTER_CONTEXT
    std::puts("C noncontext export requested");
    std::fflush(stdout);
    return exported_value(value);
#else
    return value + 2;
#endif
}

extern "C" int positive_context(int value)
{
    return exported_value(value);
}
