/*
:name: test_illegal_always_comb_other_writer
:description: A variable assigned in an always_comb procedure cannot be written by another process (IEEE 1800-2023 Section 9.2.2.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: y is assigned in an always_comb procedure and in an initial procedure
:expected_stderr_regex: test_illegal_always_comb_other_writer\.sv:(20|21):
*/
// IEEE 1800-2023 §9.2.2.2: the variables that an always_comb procedure assigns
// cannot be assigned by any other process. The initial procedure also writes y;
// a tool can report either process.

module test_illegal_always_comb_other_writer;
  logic a = 0, y;
  always_comb y = a;   // illegal: y is written here
  initial y = 1'b1;    // illegal: and here
endmodule
