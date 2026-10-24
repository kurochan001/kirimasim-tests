/*
:name: test_illegal_enum_repeated_name
:description: An enumeration that lists the same name twice is an error, even with a different value (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the name GO appears twice in one enumeration
:expected_stderr_regex: test_illegal_enum_repeated_name\.sv:19:
*/
// IEEE 1800-2023 §6.19: the names of an enumeration shall be unique; it is
// an error to give two values to the same name. The second GO has a value
// of its own, 9, that no other name uses, so only the name repeats.

module test_illegal_enum_repeated_name;
  typedef enum {GO, WAIT = 4, GO = 9} cmd_t;    // illegal: GO is listed twice
  cmd_t c;
  initial c = WAIT;
endmodule
