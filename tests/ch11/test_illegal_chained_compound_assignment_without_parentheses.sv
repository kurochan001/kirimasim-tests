/*
:name: test_illegal_chained_compound_assignment_without_parentheses
:description: A nested compound assignment has to be parenthesized when used as the right operand of another assignment
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.3.6 11.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the nested right side assignment is missing parentheses
:expected_stderr_regex: \A(?![\s\S]*test_illegal_chained_compound_assignment_without_parentheses\.sv:18:(?:\d+:)?[^\n]*(?i:(?:error|syntax|unsupported|assignment requires)))(?=[\s\S]*test_illegal_chained_compound_assignment_without_parentheses\.sv:19:(?:\d+:)?[^\n]*(?i:(?:assign|syntax|unexpected|expected)))
*/
module test_illegal_chained_compound_assignment_without_parentheses;
  int a = 3, b = 7, c = 5;

  initial begin
    a += (b *= c);
    a += b *= c;
    $display("%0d/%0d", a, b);
  end
endmodule
