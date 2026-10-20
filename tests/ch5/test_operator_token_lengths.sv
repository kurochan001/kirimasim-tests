/*
:name: test_operator_token_lengths
:description: Operators are tokens of one, two or three characters; unary operators come before their operand, binary ones between their operands, and the conditional operator uses two operator characters between three operands (IEEE 1800-2023 Section 5.5)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.5 11.3 11.4.10 11.4.5 11.4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_token_lengths.expected
*/
// IEEE 1800-2023 §5.5: an operator is a sequence of one, two or three
// characters. Unary operators are written to the left of their operand,
// binary operators between their operands, and the conditional operator
// separates its three operands with ? and :. The expressions use operators of
// each length: ~ and -, ** and <<, and the three-character <<<, >>>, ===,
// !==, ==? and <->.

module test_operator_token_lengths;
  logic signed [7:0] n = -8'sd16;
  logic [3:0] p = 4'b1010;
  int r;

  initial begin
    $display("one: %0d %b", -n, ~p);
    $display("two: %0d %b", 3 ** 2, p << 1);
    $display("three: %0d %0d %b %b", n <<< 1, n >>> 2, p === 4'b1010, p !== 4'b1010);
    $display("wildcard and equivalence: %b %b", p ==? 4'b1x1x, (p[3] <-> p[1]));
    r = p[0] ? 5 : p[1] ? 6 : 7;
    $display("conditional: %0d", r);
  end
endmodule
