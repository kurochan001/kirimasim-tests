/*
:name: test_illegal_assoc_real_member_key
:description: An associative index type cannot contain a real member (IEEE 1800-2023 Section 7.8.5)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an associative array index type contains a real member
:expected_stderr_regex: test_illegal_assoc_real_member_key\.sv:(?:21)(?::|\s)
*/
// IEEE 1800-2023 7.8.5: The prohibition on real keys applies recursively to a
// user-defined aggregate containing real.
// Oracle checks: Icarus Verilog 13.0 rejects at a different error site. The
// 5.052 release accepts the illegal design.

module test_illegal_assoc_real_member_key;
  typedef struct { int tag; real value; } key_t;
  int entries[key_t]; // illegal
endmodule
