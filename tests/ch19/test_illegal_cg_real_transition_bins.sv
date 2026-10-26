/*
:name: test_illegal_cg_real_transition_bins
:description: a real coverpoint defines a transition bin (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the coverpoint of the real formal r contains a transition bin, which real coverage does not allow
:expected_stderr_regex: test_illegal_cg_real_transition_bins\.sv:25:
*/
// Coverage of a real expression is limited to sampled value bins and
// their crosses; a transition bin on a real coverpoint is an error.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_real_transition_bins;
  covergroup cg(input real r);
    coverpoint r {
      bins up = (1.0 => 2.0);   // illegal: transition bin on a real
    }
  endgroup
endmodule
