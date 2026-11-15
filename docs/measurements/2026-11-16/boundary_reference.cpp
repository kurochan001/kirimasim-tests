#include <array>
#include <cstdint>
#include <iostream>
#include <random>
#include <vector>
#include "kirimasim/kernel/wide.h"
#include "kirimasim/valsem/value.h"

namespace k = kirimasim::kernel;
namespace w = k::wide;
namespace v = kirimasim::valsem;
using Words = std::vector<k::W4>;

v::Value value(const Words& words, unsigned width, bool sign = false) {
    std::vector<std::uint64_t> a, b;
    for (auto x : words) { a.push_back(x.a); b.push_back(x.b); }
    return v::fromWords(a, b, width, sign);
}

int main() {
    std::mt19937_64 random(0x20261116);
    std::uint64_t checks = 0;
    const auto check = [&](const Words& got, unsigned width, const v::Value& wanted) {
        ++checks;
        if (value(got, width, wanted.isSigned) != wanted) {
            std::cerr << "mismatch at " << checks << " width " << width << '\n';
            std::exit(1);
        }
    };
    for (unsigned width : {1,2,31,32,33,63,64,65,127,128,129,191,192,193,255,256,257,511,512}) {
        for (unsigned pattern = 0; pattern < 12; ++pattern) {
            Words x(w::chunks(width));
            for (unsigned i = 0; i < x.size(); ++i) {
                const auto mask = width - 64*i >= 64 ? ~std::uint64_t{0} : k::mask(width - 64*i);
                x[i] = {random() & mask, (pattern % 3 ? random() : 0) & mask};
            }
            for (bool sign : {false, true}) {
                const auto input = value(x, width, sign);
                for (std::uint64_t count : std::array<std::uint64_t,12>{0,1,7,13,31,32,63,64,65,
                                           width-1,width,width+1}) {
                    for (unsigned mode = 0; mode < 4; ++mode) {
                        Words amount{{count,0},{0,0}};
                        if (mode == 1) amount[1].a = 1;
                        if (mode == 2) amount[0].b = 1;
                        if (mode == 3) { amount[0].a = 0; amount[0].b = 1; }
                        const auto operand = value(amount, 80);
                        Words r(w::chunks(width));
                        w::shl(r.data(),x.data(),width,amount.data(),80);
                        check(r,width,v::shl(input,operand));
                        w::ashr(r.data(),x.data(),width,amount.data(),80,sign);
                        check(r,width,v::ashr(input,operand));
                        Words alias = x;
                        w::shl(alias.data(),alias.data(),width,amount.data(),80);
                        check(alias,width,v::shl(input,operand));
                        alias = x;
                        w::ashr(alias.data(),alias.data(),width,amount.data(),80,sign);
                        check(alias,width,v::ashr(input,operand));
                    }
                }
            }
            for (unsigned selected : {1U,32U,64U,65U,128U,192U,256U,width}) {
                for (std::int64_t low : {-513LL,-65LL,-64LL,-1LL,0LL,1LL,63LL,64LL,65LL,128LL,512LL}) {
                    Words r(w::chunks(selected));
                    w::bits(r.data(),selected,x.data(),width,low);
                    check(r,selected,v::bits(value(x,width),low,selected));
                    if (selected <= width) {
                        Words alias = x;
                        w::bits(alias.data(),selected,alias.data(),width,low);
                        alias.resize(w::chunks(selected));
                        check(alias,selected,v::bits(value(x,width),low,selected));
                    }
                }
            }
            for (unsigned low : {0U,1U,63U,64U,65U,128U}) {
                const unsigned resultWidth = width + low + 65;
                Words r(w::chunks(resultWidth), {~std::uint64_t{0},0});
                r.back().a &= k::mask((resultWidth - 1) % 64 + 1);
                auto expected = value(r,resultWidth);
                const auto input = value(x,width);
                for (unsigned bit = 0; bit < width; ++bit) expected.bits[low+bit] = input.bits[bit];
                w::put(r.data(),low,x.data(),width);
                check(r,resultWidth,expected);
            }
        }
    }
    std::cout << checks << " boundary/reference checks passed\n";
}
