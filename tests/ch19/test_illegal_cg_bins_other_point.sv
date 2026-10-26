/*
:name: test_illegal_cg_bins_other_point
:description: a bin uses the name of a different coverpoint as its value list (IEEE 1800-2023 Section 19.5.1.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin x of coverpoint pb names pa, another coverpoint of the same covergroup
:expected_stderr_regex: test_illegal_cg_bins_other_point\.sv:27:
*/
// The name of the coverpoint that contains the bin may stand for all
// its values. No other coverpoint name may be used, so naming pa in a
// bin of pb is an error.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_bins_other_point;
  covergroup cg(input int a, input int b);
    pa: coverpoint a;
    pb: coverpoint b {
      bins x[] = pa with (1);   // illegal: pa is another point
    }
  endgroup
endmodule
