/*
:name: test_illegal_method_implicit_variable_without_parentheses
:description: A built-in method call without parentheses whose result is selected as an implicit variable is rejected (IEEE 1800-2023 Section 5.13)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.13 13.4.1 6.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the result of the built-in method toupper is indexed as an implicit variable, but the call has no parentheses
:expected_stderr_regex: test_illegal_method_implicit_variable_without_parentheses\.sv:29:
*/
// IEEE 1800-2023 §5.13: the empty parentheses of a built-in method call
// with no arguments are optional, as in s.len, except when the call is used
// as an implicit variable (§13.4.1), where they shall always be written.
// s.toupper()[0] selects the first character of the result and is legal; on
// the marked line the same selection is made on s.toupper without
// parentheses, an error. Verilator 5.052 accepts it, and Icarus Verilog
// 13.0 rejects it with a message that it does not support the form yet,
// which is not a diagnostic of this rule.

module test_illegal_method_implicit_variable_without_parentheses;
  string s = "abc";
  byte first_a, first_b;

  initial begin
    first_a = s.toupper()[0];
    first_b = s.toupper[0];   // illegal: implicit variable without parentheses
    $display("%0d %0d %0d", s.len, first_a, first_b);
  end
endmodule
