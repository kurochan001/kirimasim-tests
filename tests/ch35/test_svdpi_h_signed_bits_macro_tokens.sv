/*
:name: test_svdpi_h_signed_bits_macro_tokens
:description: the svdpi.h of Annex I defines SV_GET_SIGNED_BITS(VALUE, N) with the same tokens as H.10.1.2, the value itself for N of 32 and otherwise a test of bit N that chooses between filling with ones and masking with SV_MASK(N) (IEEE 1800-2023 Section I.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.10.1.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_signed_bits_macro_tokens.c
:expected_stdout: @test_svdpi_h_signed_bits_macro_tokens.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists. I.3
// and H.10.1.2 both define the macro SV_GET_SIGNED_BITS(VALUE, N) with the
// same token sequence: when N is 32 it gives VALUE; otherwise it tests the
// bit (1 << (N)) of VALUE and gives VALUE with the bits above the mask set,
// ((VALUE) | ~SV_MASK(N)), or VALUE masked, ((VALUE) & SV_MASK(N)). The
// test compares the text of the macro, not the value it computes for N
// below 32.
//
// The C code removes the definition of SV_MASK after including svdpi.h, so
// that the expansion of SV_GET_SIGNED_BITS(v, n) keeps SV_MASK(n) as it is
// written, turns the expansion into a string with the # operator, drops the
// spaces, which the preprocessor keeps only where the definition has white
// space, and prints the tokens and whether they are those of the two
// clauses. Icarus Verilog 13.0 does not support DPI.

module test_svdpi_h_signed_bits_macro_tokens;
  import "DPI-C" function int dpi_signed_bits_text();

  initial $display("same tokens as H.10.1.2: %0d", dpi_signed_bits_text());
endmodule
