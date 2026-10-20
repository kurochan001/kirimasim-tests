/*
:name: test_illegal_redeclaration
:description: A name already declared in a scope cannot be declared again in the same scope (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5 3.13
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the name count is declared twice in the module
:expected_stderr_regex: test_illegal_redeclaration\.sv:(19|20):
*/
// IEEE 1800-2023 §6.5, §3.13: within one name space a name that a net, variable
// or other declaration has declared cannot be declared again. The module below
// declares count twice, with different types.

module test_illegal_redeclaration;
  logic [3:0] count;   // illegal: the first declaration of count
  int count;           // illegal: and the second
endmodule
