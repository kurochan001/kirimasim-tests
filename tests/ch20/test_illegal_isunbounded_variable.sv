/*
:name: test_illegal_isunbounded_variable
:description: $isunbounded is applied to a variable instead of a parameter name (IEEE 1800-2023 Section 20.6.3)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the argument of $isunbounded is the variable x, not a parameter name
:expected_stderr_regex: test_illegal_isunbounded_variable\.sv:20:
*/
// $isunbounded takes a parameter name, optionally qualified by a package
// or a hierarchy, and says whether its value is $. The argument here is
// the variable x.

module test_illegal_isunbounded_variable;
  int x = 3;
  initial $display("%0d", $isunbounded(x));   // illegal: not a parameter
endmodule
