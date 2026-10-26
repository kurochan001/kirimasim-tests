/*
:name: test_illegal_cg_ignore_default_bin
:description: ignore_bins names default, which explicitly ignores a default bin (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5 19.5.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: ignore_bins ig = default; explicitly ignores the default bin of the coverpoint
:expected_stderr_regex: test_illegal_cg_ignore_default_bin\.sv:27:
*/
// A default bin catches the values outside the defined bins and does not
// contribute to coverage. It cannot be explicitly ignored, so an
// ignore_bins construct that names default is an error.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_ignore_default_bin;
  covergroup cg(input int v);
    coverpoint v {
      bins d = default;
      ignore_bins ig = default;   // illegal: ignores a default bin
    }
  endgroup
endmodule
