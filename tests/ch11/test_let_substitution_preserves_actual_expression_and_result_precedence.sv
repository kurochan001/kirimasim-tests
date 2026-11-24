/*
:name: test_let_substitution_preserves_actual_expression_and_result_precedence
:description: Let expansion preserves precedence for the substituted argument and the returned expression
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_substitution_preserves_actual_expression_and_result_precedence.expected
*/
module test_let_substitution_preserves_actual_expression_and_result_precedence;
  let square_plus(left, right) = left * left + right;
  let at_index(value, index) = value[index];

  initial begin
    int base, step, offset;
    bit [4:2] packed_value;
    int unpacked_value [2:4];
    base = 2;
    step = 3;
    offset = 7;
    packed_value = 3'b100;
    unpacked_value[3] = 19;
    $display("inside=%0d", square_plus(base + step, offset));
    $display("outside=%0d", 3 * square_plus(base + step, offset));
    $display("named=%0d", 100 - square_plus(.right(4), .left(step - base)));
    $display("select=%b/%0d", at_index(packed_value, 4), at_index(unpacked_value, 3));
  end
endmodule
