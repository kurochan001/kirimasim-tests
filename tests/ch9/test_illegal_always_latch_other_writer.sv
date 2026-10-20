/*
:name: test_illegal_always_latch_other_writer
:description: A variable assigned in an always_latch procedure cannot be written by another process (IEEE 1800-2023 Section 9.2.2.3)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.3 9.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: q is assigned in an always_latch procedure and in an initial procedure
:expected_stderr_regex: test_illegal_always_latch_other_writer\.sv:(20|21):
*/
// IEEE 1800-2023 §9.2.2.3: what 9.2.2.2 says of always_comb applies to
// always_latch, so no other process can write the variables it assigns. The
// initial procedure also writes q; a tool can report either process.

module test_illegal_always_latch_other_writer;
  logic en = 0, d = 0, q;
  always_latch if (en) q <= d;   // illegal: q is written here
  initial q = 1'b0;              // illegal: and here
endmodule
