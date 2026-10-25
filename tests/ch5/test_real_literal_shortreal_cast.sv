/*
:name: test_real_literal_shortreal_cast
:description: A cast converts a real literal to the shortreal type, which rounds it to IEEE 754 single precision (IEEE 1800-2023 Section 5.7.2)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.2 6.24.1 6.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_literal_shortreal_cast.expected
*/
// IEEE 1800-2023 §5.7.2: a real literal is a double-precision value, and a
// cast (§6.24.1) converts it to the shortreal type. §6.12: shortreal is the
// single-precision type of IEEE 754. The literal 0.1 has no exact binary
// value; in single precision it is 0x3dcccccd, about 0.10000000149, so the
// cast value, put back into a real variable, differs from the literal 0.1.
// The literal 0.75 is exact in both precisions and is unchanged.
// Icarus Verilog 13.0 keeps the double-precision value in the cast (r prints
// as 0.1000000000), and the release 5.052 of Verilator stores shortreal as
// double precision.

module test_real_literal_shortreal_cast;
  real r;

  initial begin
    r = shortreal'(0.1);
    $display("bits: %h", $shortrealtobits(shortreal'(0.1)));
    $display("value: %0.11f equal_to_literal=%0d", r, r == 0.1);
    r = shortreal'(0.75);
    $display("exact: %0.11f equal_to_literal=%0d", r, r == 0.75);
  end
endmodule
