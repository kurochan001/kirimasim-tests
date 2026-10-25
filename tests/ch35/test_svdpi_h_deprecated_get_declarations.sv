/*
:name: test_svdpi_h_deprecated_get_declarations
:description: The deprecated portion of svdpi.h declares svSizeOfBitPackedArr and svSizeOfLogicPackedArr, the bit-select, part-select and whole-vector get routines of the canonical representation, and the whole-element get routines of svBitVec32 and svLogicVec32 with the return types and parameter lists that I.3 gives them (IEEE 1800-2023 Section 35.3.2, I.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_deprecated_get_declarations.c
:expected_stdout: @test_svdpi_h_deprecated_get_declarations.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3 marks a part of svdpi.h as deprecated and lets an implementation leave
// it out; that part declares the routines that copy packed arrays between the
// implementation representation and the canonical representation of chunks
// in the caller's memory, and the ones that read a bit, a part of up to 32
// bits and a whole element of an open array of packed elements.
//
// This test uses that part, so it is built only with a header that provides
// it. The C function, called once through an import, compares the address of
// each routine with a pointer to a function of the return type and parameter
// list that I.3 writes for it, at compile time (C11 _Generic in C, decltype
// in C++), and prints 1 when they are the same type. A parameter that I.3
// declares as const has the type of the pointed-to value, so const on it does
// not change the function type. Nothing is called.

module test_svdpi_h_deprecated_get_declarations;
  import "DPI-C" function void dpi_check_deprecated_get();

  initial dpi_check_deprecated_get();
endmodule
