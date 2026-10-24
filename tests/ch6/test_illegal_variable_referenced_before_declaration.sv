/*
:name: test_illegal_variable_referenced_before_declaration
:description: A variable cannot be referenced by its simple name before its declaration (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable count is assigned in an initial procedure that comes before its declaration
:expected_stderr_regex: test_illegal_variable_referenced_before_declaration\.sv:21:
*/
// IEEE 1800-2023 §6.21: a variable declaration shall precede any simple
// (non-hierarchical) reference to the variable. The initial procedure
// assigns count by its simple name on a line before the declaration of
// count in the same module.
// The design is accepted by Verilator 5.052.

module test_illegal_variable_referenced_before_declaration;
  initial count = 5;    // illegal: count is declared on the next line
  int count;
endmodule
