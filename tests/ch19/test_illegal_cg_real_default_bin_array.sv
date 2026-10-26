/*
:name: test_illegal_cg_real_default_bin_array
:description: a real default bin uses the [] bin-array notation (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default bin of the real coverpoint is declared with [], which a real default bin does not allow
:expected_stderr_regex: test_illegal_cg_real_default_bin_array\.sv:25:
*/
// A default bin for a real expression shall not have an array of bins:
// neither the [] notation nor the [N] notation is allowed.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_real_default_bin_array;
  covergroup cg(input real r);
    coverpoint r {
      bins d[] = default;   // illegal: array of real default bins
    }
  endgroup
endmodule
