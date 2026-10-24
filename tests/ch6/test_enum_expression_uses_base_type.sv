/*
:name: test_enum_expression_uses_base_type
:description: an enum variable or name in an expression is converted to its base type, int by default, so it brings the width and sign of that base into the expression (IEEE 1800-2023 Section 6.19.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.4 11.6.1 11.8.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_expression_uses_base_type.expected
*/
// IEEE 1800-2023 §6.19.4: an enum variable or name used in an expression is
// cast to the base type of its enum, int when no base type is given. So it
// has the width of the base ($bits of an addition with a 1-bit operand is 4
// for a bit [3:0] base and 32 for the int base, §11.6.1) and its sign
// (§11.8.1): the encoding 4'b1111 is 15 for bit [3:0], -1 for bit signed
// [3:0], and an int enum name of -1 is -1. Adding an unsigned and a signed
// operand makes the whole expression unsigned, so U15 + I_NEG is 14 in 32
// bits.

module test_enum_expression_uses_base_type;
  typedef enum bit [3:0] {U0, U15 = 15} u_t;
  typedef enum bit signed [3:0] {SZ, SN = -1} s_t;
  typedef enum {I0, I_NEG = -1} i_t;
  u_t uv = U15;
  s_t sv = SN;
  i_t iv = I_NEG;
  int r;

  initial begin
    $display("bits: %0d %0d %0d", $bits(uv + 1'b1), $bits(sv + 1'b1), $bits(iv + 1'b1));
    r = uv;
    $display("unsigned base: %0d neg=%0d", r, uv < 0);
    r = sv;
    $display("signed base: %0d neg=%0d", r, sv < 0);
    r = iv;
    $display("int base: %0d neg=%0d", r, iv < 0);
    r = SN + I_NEG;
    $display("SN + I_NEG = %0d", r);
    r = U15 + I_NEG;
    $display("U15 + I_NEG = %0d", r);
    r = uv * 2;
    $display("uv * 2 = %0d", r);
  end
endmodule
