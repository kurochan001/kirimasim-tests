/*
:name: test_primary_literal_categories_as_operands
:description: Each of the four kinds of primary literal, a number, a time literal, an unbased unsized literal and a string literal, is an operand of an expression and gives its own value there (IEEE 1800-2023 Section 5.7)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7 5.7.1 5.7.2 5.8 5.9
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_primary_literal_categories_as_operands.expected
*/
// IEEE 1800-2023 §5.7: a primary literal is a number, a time literal, an
// unbased unsized literal or a string literal. Each kind is used below as an
// operand of an operator, so the expression shows the value the literal has:
// - numbers: the sized hexadecimal 4'hA (§5.7.1) plus 3 is 13, and the real
//   1.5e1 in scientific notation (§5.7.2) divided by 2 is 7.5;
// - time literals (§5.8): a time literal is a realtime value scaled to the
//   current time unit, 1ns here, so 1ns + 500ps is 1.5 and 2ps + 3 is 3.002;
// - unbased unsized literals (§5.7.1): '1 and '0 set all the bits of the
//   value to 1 or 0 and take the width of the expression they are in, so
//   8'h0F & '1 is 0f and 8'hF0 | '0 is f0, and ~'0 assigned to an 8-bit
//   variable is ff;
// - string literals (§5.9): "AB" is a 16-bit unsigned value with one byte per
//   character, so "AB" + 0 is 16706 (16'h4142), and "AB" == 16'h4142 is 1.
// Icarus Verilog 13.0 and the 5.054 release of Verilator produce this output.

`timescale 1ns/1ps

module test_primary_literal_categories_as_operands;
  logic [7:0] u;
  int s_val;
  realtime t1, t2;

  initial begin
    $display("number: %0d %0.2f", 4'hA + 3, 1.5e1 / 2);
    t1 = 1ns + 500ps;
    t2 = 2ps + 3;
    $display("time: %0.3f %0.3f", t1, t2);
    u = ~'0;
    $display("unbased: %h %h %h", 8'h0F & '1, 8'hF0 | '0, u);
    s_val = "AB" + 0;
    $display("string: %0d %0d", s_val, "AB" == 16'h4142);
  end
endmodule
