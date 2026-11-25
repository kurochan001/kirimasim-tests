/*
:name: test_dpi_portable_multiword_bit_and_scalar
:description: A prebuilt DPI object exchanges a 65-bit packed value and a scalar inout counter
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.2 H.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_portable_multiword_bit_and_scalar.c
:expected_stdout: @test_dpi_portable_multiword_bit_and_scalar.expected
*/
module test_dpi_portable_multiword_bit_and_scalar;
  import "DPI-C" function int portable_words(input bit [64:0] data,
                                              output bit [64:0] rotated,
                                              inout int calls);

  bit [64:0] rotated;
  int calls = 40;
  int seen;

  initial begin
    seen = portable_words(65'h1_89abcdef_01234567, rotated, calls);
    $display("DPI ABI bit=%017h calls=%0d top=%0d", rotated, calls, seen);
    seen = portable_words(65'h0_13579bdf_2468ace0, rotated, calls);
    $display("DPI ABI bit=%017h calls=%0d top=%0d", rotated, calls, seen);
  end
endmodule
