/*
:name: test_cast_casting_type_forms_and_const
:description: every form of casting type works (integer and real type keywords, a typedef, a package type, a type parameter, a constant size, signed and unsigned, string and const), casts are constant expressions when their operand is, and a const cast keeps the type of its operand (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12.2 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_casting_type_forms_and_const.expected
*/
// IEEE 1800-2023 §6.24.1: the casting type before the apostrophe is a
// simple type (an integer or real type keyword, a type name, possibly with
// a package scope, or a type parameter), a constant primary that gives the
// size, signed or unsigned, string, or const, and a cast whose operand is a
// constant expression is a constant cast. A cast to a type gives the value a
// variable of that type would get: int'(7.5) rounds to 8 (§6.12.2),
// byte'(12'h0f6) keeps 8'hf6 = -10, a 3-bit type keeps the 3 low bits, and
// string'(16'h4869) is "Hi" (§6.16). The localparams L and C use casts in
// constant expressions. A const cast passes the type of its operand through
// unchanged: the signed 6-bit -3 is sign-extended when assigned to 8 bits,
// $bits is still 6, and a real stays real (2.5 * 3 is 7.5, not 9).
// Icarus Verilog 13.0 does not parse const casts (syntax error).

package ctf_pkg;
  typedef bit [5:0] w6_t;
endpackage

module test_cast_casting_type_forms_and_const;
  typedef bit [2:0] u3_t;
  localparam type LT = byte;
  parameter int P = 5;
  localparam int Q = 2;
  localparam int L = int'(2.5) + 4'(5'd18);
  localparam int C = const'(P) + 1;
  logic signed [5:0] xs = -6'sd3;
  real rv = 2.5;
  logic [7:0] r8;

  initial begin
    $display("integer types: int=%0d byte=%0d", int'(7.5), byte'(12'h0f6));
    $display("real type: %0.1f", real'(7) / 2);
    $display("type names: u3=%0d pkg=%0d type parameter=%0d",
             u3_t'(4'd13), ctf_pkg::w6_t'(-1), LT'(300));
    $display("size: %0d %0d %0d constant=%0d", P'(9'h1ff), (Q+1)'(4'b1111), 6'(2), L);
    $display("signing: %0d %0d", signed'(4'b1000), unsigned'(-4));
    $display("string: %s", string'(16'h4869));
    r8 = const'(xs);
    $display("const: ext=%b bits=%0d real=%0.1f constant=%0d",
             r8, $bits(const'(xs)), const'(rv) * 3, C);
  end
endmodule
