/*
:name: test_illegal_enum_from_int
:description: An int value cannot be assigned to an enum variable without a cast (IEEE 1800-2023 Section 6.19.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an int variable is assigned to an enum variable without a cast
:expected_stderr_regex: test_illegal_enum_from_int\.sv:22:
*/
// IEEE 1800-2023 §6.19.3: enumerated types are strongly typed, and an
// expression of another type is assigned to an enum variable only through a
// cast. Here an int is assigned directly, even though its value names a member.

module test_illegal_enum_from_int;
  typedef enum {RED, GREEN, BLUE} color_t;
  color_t c;
  int i = 1;
  initial c = i;       // illegal: an int assigned to color_t
endmodule
