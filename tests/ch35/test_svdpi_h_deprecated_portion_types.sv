/*
:name: test_svdpi_h_deprecated_portion_types
:description: The deprecated portion of svdpi.h defines SV_CANONICAL_SIZE(WIDTH) as WIDTH+31 shifted right by 5, svBitVec32 as unsigned int, svLogicVec32 as a structure of two unsigned int members c and d in that order, and svBitPackedArrRef and svLogicPackedArrRef as aliases of void* (IEEE 1800-2023 Section 35.3.2, I.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.5 H.14 I.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_deprecated_portion_types.c
:expected_stdout: @test_svdpi_h_deprecated_portion_types.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3 marks a part of svdpi.h as deprecated and lets an implementation leave
// it out; the part it gives defines the canonical representation of packed
// arrays that the deprecated routines use: SV_CANONICAL_SIZE(WIDTH) as
// WIDTH+31 shifted right by 5, the number of 32-bit chunks, svBitVec32 as
// unsigned int, svLogicVec32 as a structure with the unsigned int members c
// and d, and svBitPackedArrRef and svLogicPackedArrRef as aliases of void*
// that refer to a standalone packed array.
//
// This test uses that part, so it is built only with a header that provides
// it. The C function, called once through an import, prints 1 when the macro
// gives 1, 1, 2, 2 and 3 chunks for widths 1, 32, 33, 64 and 65, when
// svBitVec32 is unsigned int, when svLogicVec32 has exactly the size of two
// unsigned ints with c before d and both of that type, and when both
// reference types are void*; the types are compared at compile time (C11
// _Generic in C, decltype in C++) and the member order with offsetof.

module test_svdpi_h_deprecated_portion_types;
  import "DPI-C" function void dpi_check_deprecated_types();

  initial dpi_check_deprecated_types();
endmodule
