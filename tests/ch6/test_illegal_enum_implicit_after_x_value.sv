/*
:name: test_illegal_enum_implicit_after_x_value
:description: An enum name without a value cannot follow a name whose value has an x bit (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the name C has no value and follows B, whose value 2'b1x has an x bit
:expected_stderr_regex: test_illegal_enum_implicit_after_x_value\.sv:20:
*/
// IEEE 1800-2023 §6.19: a name without a value gets the value of the
// previous name plus one; when the previous name has a value with x or z
// bits this is a syntax error. The 4-state base allows B = 2'b1x itself, so
// only the name C after it is in error.

module test_illegal_enum_implicit_after_x_value;
  typedef enum logic [1:0] {A = 2'b00, B = 2'b1x, C} e_t;    // illegal: C follows an x value
  e_t e;
  initial e = A;
endmodule
