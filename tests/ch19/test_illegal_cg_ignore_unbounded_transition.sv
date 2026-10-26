/*
:name: test_illegal_cg_ignore_unbounded_transition
:description: an ignored transition has an unbounded varying length (IEEE 1800-2023 Section 19.5.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ignored transition uses the nonconsecutive repetition 1[=2], whose length is unbounded and varies
:expected_stderr_regex: test_illegal_cg_ignore_unbounded_transition\.sv:26:
*/
// An ignored transition bin shall not specify a sequence of unbounded
// or undetermined varying length. Nonconsecutive repetition such as
// 1[=2] has such a length.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_ignore_unbounded_transition;
  covergroup cg(input int v);
    coverpoint v {
      ignore_bins ig = (1[=2]);   // illegal: unbounded length
    }
  endgroup
endmodule
