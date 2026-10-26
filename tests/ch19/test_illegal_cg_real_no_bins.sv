/*
:name: test_illegal_cg_real_no_bins
:description: a real coverpoint declares no explicit bins (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real coverpoint r has no explicit bins, and real coverpoints get no automatic bins
:expected_stderr_regex: test_illegal_cg_real_no_bins\.sv:25:
*/
// A coverpoint of a real expression shall have at least one explicit
// bins construct; no automatic bins are created for it. The coverpoint
// r here has none.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_real_no_bins;
  covergroup cg(input real r);
    coverpoint r;   // illegal: real coverpoint without explicit bins
  endgroup
endmodule
