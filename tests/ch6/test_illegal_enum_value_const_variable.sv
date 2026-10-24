/*
:name: test_illegal_enum_value_const_variable
:description: An enum name value cannot use a const variable (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19 6.20.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the enum name A uses the const variable START
:expected_stderr_regex: test_illegal_enum_value_const_variable\.sv:21:
*/
// IEEE 1800-2023 §6.19: const variables are not allowed in the value of an
// enum name. A const variable (§6.20.6) gets its value at run time, not at
// elaboration, so START cannot give the value of A, although it has a
// constant initializer.

module test_illegal_enum_value_const_variable;
  const int START = 4;
  typedef enum {A = START, B} e_t;    // illegal: START is a const variable
  e_t e;
  initial e = B;
endmodule
