/*
:name: test_expression_type_bitwise_sign_self_determined_real
:description: an unsigned operand makes a bitwise result unsigned with zero extension, a self-determined operand keeps its own size and sign inside a larger expression, a real operand makes the result real while a nonreal context-determined operand is evaluated on its own first, and a real coerced to an integer is signed (IEEE 1800-2023 Section 11.8.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.8.1 11.8.2 11.4.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expression_type_bitwise_sign_self_determined_real.expected
*/
// IEEE 1800-2023 §11.4.8: when either operand of a binary bitwise operator is
// unsigned, the result is unsigned and the shorter operand is zero-extended;
// when both are signed, the result is signed and extension is by sign.
// §11.8.1: a self-determined operand has the size and sign it has by itself,
// whatever the rest of the expression; a real operand makes the result real;
// a real converted to an integer by coercion is signed. §11.8.2: when an
// operator gives a real result, a context-determined operand that is not
// real is evaluated as self-determined and converted to real just before the
// operator is applied.
// 4'sb1000 | 4'b0001 in an int is 9 (zero-extended), with two signed
// operands it is -7; 4'sb1010 & 8'hff is 0a, with 8'shff it is fa. The
// operand of a concatenation is self-determined, so {a + b} keeps 4 bits and
// is 0 where (a + b) in the 8-bit context is 16; the operands of == are sized
// among themselves (0 == 0 in 4 bits) and the signed operands of < stay
// signed in an unsigned context. 8'd200 + 100.0 is 300.0, but in
// 8'd200 + 8'd100 + 0.5 the inner sum is 8 bits wide (44) before 0.5 is
// added, and i / 2 + 0.5 divides integers (3.5). -3.0 coerced to 64 bits and
// to a 40-bit task argument is sign-extended.

module test_expression_type_bitwise_sign_self_determined_real;
  int r1, r2;
  logic [7:0] u8;
  logic [3:0] a = 4'hf, b = 4'h1;
  int i = 7;
  real rv = -3.0;
  real x1, x2, x3;
  bit [63:0] b64;

  task automatic show40(input logic [39:0] v);
    $display("40-bit argument: %h", v);
  endtask

  initial begin
    r1 = 4'sb1000 | 4'b0001;
    r2 = 4'sb1000 | 4'sb0001;
    $display("| in int: %0d %0d", r1, r2);
    $display("& widths: %h %h, unsigned < 0: %0d", 4'sb1010 & 8'hff, 4'sb1010 & 8'shff,
             (4'sb1000 ^ 4'b0000) < 0);
    u8 = (a + b) >> 1;
    $write("context vs self-determined: %0d", u8);
    u8 = {a + b} >> 1;
    $write(" %0d", u8);
    u8 = ((a + b) == 4'b0000);
    $write(" %0d", u8);
    u8 = (4'sb1111 < 4'sd0) + 8'd0;
    $display(" %0d", u8);
    x1 = 8'd200 + 100.0;
    x2 = 8'd200 + 8'd100 + 0.5;
    x3 = i / 2 + 0.5;
    $display("real: %0.2f %0.2f %0.2f", x1, x2, x3);
    b64 = rv;
    $display("64-bit coercion: %h", b64);
    show40(rv);
  end
endmodule
