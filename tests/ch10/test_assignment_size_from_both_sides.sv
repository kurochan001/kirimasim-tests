/*
:name: test_assignment_size_from_both_sides
:description: an assignment first sizes its left-hand side and its right-hand side by the expression size rules, so the wider of the two sets the width at which the operators of the right-hand side are evaluated, and self-determined operands keep their own width (IEEE 1800-2023 Section 10.7)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.7 11.6.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_size_from_both_sides.expected
*/
// IEEE 1800-2023 §10.7: the first step of an assignment determines the size
// of its left-hand side and of its right-hand side by the standard rules of
// expression size, and the size of the left-hand side forms the context of
// the right-hand side. §11.6.1: the operands of + and the first operand of >>
// are context-determined, so they are evaluated at the largest of the sizes
// of the operands and of the left-hand side; the operand of a concatenation
// is self-determined; and the size of a concatenation of variables on the
// left-hand side is the sum of their sizes.
//
// a = 8'hF0 and b = 8'h30, whose sum 'h120 needs 9 bits.
// - (a + b) >> 5 into the 4-bit n4: the right-hand side has 8 bits, more
//   than n4, so the sum is evaluated in 8 bits, 'h20, and shifted to 1. An
//   evaluation in the 4 bits of n4 would give 0, and one with the carry
//   would give 'h9.
// - the same into the 8-bit n8 gives 1, and into the 9-bit n9 the sum keeps
//   its carry: 'h120 >> 5 = 9.
// - a + b into {c, s}, 9 bits on the left, keeps the carry in c: 1 and 'h20.
// - {a + b} into n9: the operand of the concatenation is 8 bits whatever the
//   left-hand side is, so the carry is lost: 'h020.
// - a + b into n9: 'h120.

module test_assignment_size_from_both_sides;
  logic [7:0] a, b;
  logic [3:0] n4;
  logic [7:0] n8, s;
  logic [8:0] n9;
  logic       c;

  initial begin
    a = 8'hF0;
    b = 8'h30;
    n4 = (a + b) >> 5;
    $display("4-bit target: %0d", n4);
    n8 = (a + b) >> 5;
    $display("8-bit target: %0d", n8);
    n9 = (a + b) >> 5;
    $display("9-bit target: %0d", n9);
    {c, s} = a + b;
    $display("concatenated target: c=%b s=%h", c, s);
    n9 = {a + b};
    $display("self-determined operand: %h", n9);
    n9 = a + b;
    $display("context-determined operands: %h", n9);
  end
endmodule
