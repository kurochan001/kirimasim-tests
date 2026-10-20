/*
:name: test_illegal_enum_increment_overflow
:description: Automatic increment past the largest value of the base type of an enumeration is an error (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the name Q would get the value 4, which bit [1:0] cannot hold
:expected_stderr_regex: test_illegal_enum_increment_overflow\.sv:19:
*/
// IEEE 1800-2023 §6.19: incrementing the largest value that the base type can
// represent to get the value of the next name is an error. P is 3, the largest
// value of bit [1:0], so Q has no value.

module test_illegal_enum_increment_overflow;
  enum bit [1:0] {P = 2'd3, Q} e;   // illegal: Q would be 4
endmodule
