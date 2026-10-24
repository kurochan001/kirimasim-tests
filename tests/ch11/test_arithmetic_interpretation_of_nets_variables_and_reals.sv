/*
:name: test_arithmetic_interpretation_of_nets_variables_and_reals
:description: arithmetic reads an unsigned net as unsigned, a signed net as signed two's complement and a real variable as signed floating point, and a value stored in a net or variable takes the signedness and representation of the destination (IEEE 1800-2023 Section 11.4.3.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3.1 11.8.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arithmetic_interpretation_of_nets_variables_and_reals.expected
*/
// IEEE 1800-2023 §11.4.3.1: a value assigned to an unsigned net or variable
// is treated as unsigned and one assigned to a signed net or variable as
// signed, in two's-complement representation; a value assigned to a real
// variable is held in floating point. Arithmetic operators read an unsigned
// net as unsigned, a signed net as signed two's complement and a real
// variable as signed floating point (Table 11-7).
// un and sn are nets driven with the same bits 8'hf4. In /, % and - with an
// int literal the expression is 32 bits wide (§11.8.1): un is zero-extended
// and read as 244, so un / 4 = 61, un % 5 = 4 and un - 250 wraps to
// 4294967290; sn is sign-extended and read as -12, so the results are -3, -2
// and -262. rn holds -12.5, and rn / 4, rn + 20 and -rn are -3.125, 7.5 and
// 12.5. Then -12 is stored in an unsigned byte (244, bits 11110100), a
// signed byte (-12, the same bits), a real (-12.0, whose IEEE 754 bits are
// c028000000000000), a 16-bit unsigned variable (65524) and an int (-12),
// and read back by division. The unsigned value 8'hf4 stored in the signed
// byte keeps its bits and reads -12, and stored in the real reads 244.0; the
// signed byte stored in the 16-bit variable is sign-extended (65524), the
// unsigned byte stored in the int is zero-extended (244).

module test_arithmetic_interpretation_of_nets_variables_and_reals;
  wire [7:0] un = 8'hf4;
  wire signed [7:0] sn = 8'hf4;
  real rn = -12.5;
  logic [7:0] uv;
  logic signed [7:0] sv;
  real rv;
  logic [15:0] uw;
  int iv;

  initial begin
    #1;
    $display("unsigned net: %0d %0d %0d %0d", un, un / 4, un % 5, un - 250);
    $display("signed net: %0d %0d %0d %0d", sn, sn / 4, sn % 5, sn - 250);
    $display("real variable: %0.3f %0.3f %0.3f", rn / 4, rn + 20, -rn);
    uv = -12;
    sv = -12;
    rv = -12;
    uw = -12;
    iv = -12;
    $display("stored -12: %0d %0d %0.1f %0d %0d", uv, sv, rv, uw, iv);
    $display("representation: %b %b %h", uv, sv, $realtobits(rv));
    $display("read back: %0d %0d %0.1f %0d %0d", uv / 4, sv / 4, rv / 4, uw / 4, iv / 4);
    sv = 8'hf4;
    rv = 8'hf4;
    $display("unsigned value stored: %0d %b %0.1f", sv, sv, rv);
    sv = -12;
    uv = 8'hf4;
    uw = sv;
    iv = uv;
    $display("extended into wider: %0d %0d", uw, iv);
  end
endmodule
