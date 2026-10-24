/*
:name: test_illegal_enum_value_from_variable
:description: An enum name value that reads a module variable is not an elaboration-time constant and is an error (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19 6.20
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the enum name A is given by the variable start, which is not an elaboration-time constant expression
:expected_stderr_regex: test_illegal_enum_value_from_variable\.sv:22:
*/
// IEEE 1800-2023 §6.19: the value of an enum name is an elaboration-time
// constant expression (§6.20): it may use parameters, local parameters,
// genvars, other enum names and constant functions of these. A module
// variable is none of these, even with an initializer, so using it as the
// value of A is an error.

module test_illegal_enum_value_from_variable;
  int start = 3;
  typedef enum {A = start, B} e_t;    // illegal: start is a variable
  e_t e;
  initial e = B;
endmodule
