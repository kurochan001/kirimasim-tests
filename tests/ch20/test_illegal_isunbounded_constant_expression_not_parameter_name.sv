/*
:name: test_illegal_isunbounded_constant_expression_not_parameter_name
:description: A constant arithmetic expression is not a parameter name for isunbounded
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the argument is an arithmetic expression although it uses a parameter
:expected_stderr_regex: test_illegal_isunbounded_constant_expression_not_parameter_name\.sv:17:(?:\d+:)?[^\n]*(?i:(?:\$isunbounded[^\n]*parameter|parameter[^\n]*\$isunbounded))
*/
module test_illegal_isunbounded_constant_expression_not_parameter_name;
  parameter LIMIT = 5;
  initial begin
    $display("parenthesized expression=%0d", $isunbounded(LIMIT + 1)); // illegal
  end
endmodule
