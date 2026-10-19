/*
:name: test_real_conversion_wide_and_unknown
:description: Conversion to real of vectors wider than 64 bits, of a negative signed vector and of a vector with x and z bits (IEEE 1800-2023 Section 6.12.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_real_conversion_wide_and_unknown.expected
*/
// IEEE 1800-2023 §6.12.1: an integral value assigned to a real variable is
// converted to real. The whole value is converted, also when the vector is
// wider than 64 bits, and a signed vector keeps its sign. Bits that are x or
// z are taken as 0: 16'b1010_xx00_11zz_0101 converts as 16'ha0c5, 41157.
// The values here are exact in a real, so %.1f prints them exactly.

module test_real_conversion_wide_and_unknown;
  real r;
  bit [127:0] w;
  logic signed [79:0] neg;
  logic [15:0] lx;

  initial begin
    w = 128'h1_0000_0000_0000_0000;
    r = w;
    $display("2**64: %.1f", r);
    w = 128'h1_0000_0000_0000_0000_0000_0000;
    r = w;
    $display("2**96: %.1f", r);
    neg = -80'sd5;
    r = neg;
    $display("80-bit -5: %.1f", r);
    lx = 16'b1010_xx00_11zz_0101;
    r = lx;
    $display("with x and z bits: %.1f", r);
  end
endmodule
