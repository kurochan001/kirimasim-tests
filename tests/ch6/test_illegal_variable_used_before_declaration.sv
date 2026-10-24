/*
:name: test_illegal_variable_used_before_declaration
:description: A variable cannot be used before its declaration; only implicit nets are exempt (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure assigns count before the declaration of count
:expected_stderr_regex: test_illegal_variable_used_before_declaration\.sv:(22|23):
*/
// IEEE 1800-2023 §6.5: data have to be declared before they are used; the
// only exception are implicit nets (6.10), which a procedural assignment
// never creates. Here the initial procedure writes count on the line before
// count is declared in the same module, so the design is illegal. A tool can
// report the use, or the declaration that comes after it.
// Oracle checks: the 5.052 release accepts the design.

module test_illegal_variable_used_before_declaration;
  initial count = 5;   // illegal: count is not declared yet
  int count;
endmodule
