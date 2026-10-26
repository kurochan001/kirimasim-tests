/*
:name: test_svdpi_h_deprecated_size_and_types
:description: Where the deprecated SV3.1a compatibility part of svdpi.h is provided, SV_CANONICAL_SIZE gives the number of 32-bit chunks of a width, svBitVec32 is uint32_t, svLogicVec32 is a structure of two unsigned int members c then d, and the two packed-array references are void* (IEEE 1800-2023 Section H.14.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.14.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_deprecated_size_and_types.c
:expected_stdout: @test_svdpi_h_deprecated_size_and_types.expected
*/
// IEEE 1800-2023 §H.14.2: the deprecated SV3.1a compatibility part of svdpi.h
// defines SV_CANONICAL_SIZE(WIDTH) as (WIDTH+31)>>5, the number of 32-bit
// chunks of a packed array of that width, svBitVec32 as a chunk of a packed
// bit array of type uint32_t, svLogicVec32 as a chunk of a packed logic array,
// a structure with the two unsigned int members c and d in that order, and
// svBitPackedArrRef and svLogicPackedArrRef as void* references to a standalone
// packed array. H.14 says that this part is deprecated and an implementation
// need not provide it, so a test that uses it is built only against a header
// that does.
//
// The C function, called once through an import, compares the types at compile
// time (C11 _Generic in C, decltype in C++) and the structure layout with
// offsetof, and prints the number of chunks the macro gives for widths that
// fall on and around the boundaries of a 32-bit chunk.

module test_svdpi_h_deprecated_size_and_types;
  import "DPI-C" function void dpi_check_deprecated_types();

  initial dpi_check_deprecated_types();
endmodule
