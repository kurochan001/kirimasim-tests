/*
:name: test_illegal_enum_x_value_default_int_base
:description: An enum without a base type, whose base is the 2-state int, cannot give a name a value with x bits (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the name B of an enum with the implicit int base is given the value 'x
:expected_stderr_regex: test_illegal_enum_x_value_default_int_base\.sv:19:
*/
// IEEE 1800-2023 §6.19: in an enum with no explicit base type (the base is
// then int) or with an explicit 2-state base, a name with an x or z value
// is a syntax error. Here the base is the implicit int.

module test_illegal_enum_x_value_default_int_base;
  typedef enum {A = 0, B = 'x} e_t;    // illegal: x value with the implicit int base
  e_t e;
  initial e = A;
endmodule
