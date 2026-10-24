/*
:name: test_assignment_expression_concat_target_unsigned_sum_width
:description: an assignment expression whose target is a concatenation returns an unsigned value as wide as the sum of the widths of the concatenated targets, even when every target is signed (IEEE 1800-2023 Section 11.3.6)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_expression_concat_target_unsigned_sum_width.expected
*/
// IEEE 1800-2023 §11.3.6: an assignment in parentheses inside an expression
// casts its right-hand side to the type of its target, writes the target and
// returns that cast value. When the target is a concatenation, the value
// returned is of an unsigned integral type whose width is the sum of the
// widths of the concatenated operands.
// The targets a (3 bits) and b (5 bits) are both signed, so the result of
// ({a, b} = ...) is 8 bits and unsigned. All ones read into int r give 255,
// not -1; (... ) < 0 is false and adding 1 gives 256, not 0. A 12-bit value
// is cut to its low 8 bits (8'hbc = 188), not kept at 12 bits or cut to the
// 5 bits of the wider operand. For contrast, the result of an assignment to
// the signed 8-bit variable c alone is signed: -1 and less than 0.
// Icarus Verilog 13.0 and Verilator 5.052 do not parse a concatenation as
// the target of an assignment inside an expression.

module test_assignment_expression_concat_target_unsigned_sum_width;
  logic signed [2:0] a;
  logic signed [4:0] b;
  logic signed [7:0] c;
  int r;
  bit lt;

  initial begin
    r = ({a, b} = 8'shff);
    $display("r = ({a, b} = 8'shff): %0d", r);
    lt = (({a, b} = 8'shff) < 0);
    $display("({a, b} = 8'shff) < 0: %0d", lt);
    r = ({a, b} = 8'shff) + 1;
    $display("({a, b} = 8'shff) + 1: %0d", r);
    r = ({a, b} = 12'habc);
    $display("r = ({a, b} = 12'habc): %0d a=%b b=%b", r, a, b);
    r = (c = 8'shff);
    lt = ((c = 8'shff) < 0);
    $display("r = (c = 8'shff): %0d, < 0: %0d", r, lt);
  end
endmodule
