/*
:name: test_illegal_always_ff_other_writer
:description: A variable assigned in an always_ff procedure cannot be written by another process (IEEE 1800-2023 Section 9.2.2.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.4 9.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: q is assigned in an always_ff procedure and in an initial procedure
:expected_stderr_regex: test_illegal_always_ff_other_writer\.sv:(21|22):
*/
// IEEE 1800-2023 §9.2.2.4: the variables that an always_ff procedure assigns
// cannot be written by any other process, as for always_comb (9.2.2.2). The
// initial procedure also writes q; a tool can report either process.

module test_illegal_always_ff_other_writer;
  logic clk = 0;
  int q;
  always_ff @(posedge clk) q <= 1;   // illegal: q is written here
  initial q = 2;                     // illegal: and here
endmodule
