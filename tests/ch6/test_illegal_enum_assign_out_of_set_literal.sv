/*
:name: test_illegal_enum_assign_out_of_set_literal
:description: A literal value that no member has cannot be assigned to an enum variable without a cast (IEEE 1800-2023 Section 6.19.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the literal 7, which is not a value of color_t, is assigned directly to the color_t variable c
:expected_stderr_regex: test_illegal_enum_assign_out_of_set_literal\.sv:24:
*/
// IEEE 1800-2023 §6.19.3: enumerated types are strongly typed; a value
// outside the enumeration set can be put into an enum variable only with an
// explicit cast (or when the variable is a union member). color_t has the
// values 0, 1 and 2, and 7 is assigned to c without a cast.

module test_illegal_enum_assign_out_of_set_literal;
  typedef enum {RED, GREEN, BLUE} color_t;
  color_t c;
  initial begin
    c = GREEN;
    c = 7;    // illegal: 7 is not a color_t value and there is no cast
  end
endmodule
