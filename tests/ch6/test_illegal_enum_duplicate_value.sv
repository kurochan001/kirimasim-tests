/*
:name: test_illegal_enum_duplicate_value
:description: Two names of an enumeration cannot have the same value, also when one value comes from automatic increment (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the names MID and HIGH of the enumeration both have the value 3
:expected_stderr_regex: test_illegal_enum_duplicate_value\.sv:19:
*/
// IEEE 1800-2023 §6.19: the names of an enumeration need distinct values,
// whether set explicitly or by incrementing the previous one. MID follows LOW =
// 2 and so gets 3, which HIGH is also given.

module test_illegal_enum_duplicate_value;
  enum {LOW = 2, MID, HIGH = 3} level;   // illegal: MID and HIGH are both 3
endmodule
