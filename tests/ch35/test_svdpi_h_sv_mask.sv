/*
:name: test_svdpi_h_sv_mask
:description: svdpi.h defines SV_MASK(N) as the complement of -1 shifted left by N, an int whose N low bits are 1, and SV_GET_UNSIGNED_BITS masks with it (IEEE 1800-2023 Section 35.3.2, H.10.1.2, I.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.10.1.2 I.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_sv_mask.c
:expected_stdout: @test_svdpi_h_sv_mask.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI uses svdpi.h (H.10.1). H.10.1.2
// and I.3 define SV_MASK(N) as the bitwise complement of -1 shifted left by
// N, so with an int -1 the mask is an int whose N low bits are 1, and
// SV_GET_UNSIGNED_BITS(VALUE, N) keeps the N low bits of VALUE with it.
//
// The C function, called once through an import, prints 1 when the
// replacement list of SV_MASK, made into a string by the preprocessor, is
// the expression that H.10.1.2 and I.3 give, when SV_MASK(5) has type int,
// compared at compile time (C11 _Generic in C, decltype in C++), and when
// SV_MASK gives 0x1, 0x1f and 0x7fffffff for 1, 5 and 31. A mask written
// another way prints 0 on the first line, and one with an unsigned operand
// has type unsigned int and prints 0 on the second.
// The svdpi.h of Verilator 5.052 writes it with 0xffffffffU (see
// docs/simulator-differences.md), so :oracle: lists no simulator.

module test_svdpi_h_sv_mask;
  import "DPI-C" function void dpi_check_sv_mask();

  initial dpi_check_sv_mask();
endmodule
