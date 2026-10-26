/*
:name: test_illegal_cg_real_bins_with
:description: a bin of a real coverpoint has a with clause (IEEE 1800-2023 Section 19.5.1.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin of the real coverpoint r uses with, which real bins do not allow
:expected_stderr_regex: test_illegal_cg_real_bins_with\.sv:26:
*/
// A with clause selects the candidate values for which its expression
// is true, but with expressions are not allowed for bins of a real
// type.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_real_bins_with;
  covergroup cg(input real r);
    coverpoint r {
      bins b = {[0.0:1.0]} with (item > 0.5);   // illegal: real with
    }
  endgroup
endmodule
