/*
:name: test_illegal_enum_from_other_enum
:description: A member of one enum type cannot be assigned to a variable of another enum type (IEEE 1800-2023 Section 6.19.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a member of size_t is assigned to a variable of color_t
:expected_stderr_regex: test_illegal_enum_from_other_enum\.sv:22:
*/
// IEEE 1800-2023 §6.19.3: an enum variable can hold only the members of its own
// type unless a cast is used. LARGE belongs to another enumeration, even though
// its value (1) is also the value of GREEN.

module test_illegal_enum_from_other_enum;
  typedef enum {RED, GREEN} color_t;
  typedef enum {SMALL, LARGE} size_t;
  color_t c;
  initial c = LARGE;   // illegal: a member of size_t
endmodule
