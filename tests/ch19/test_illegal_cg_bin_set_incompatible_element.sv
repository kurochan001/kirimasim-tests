/*
:name: test_illegal_cg_bin_set_incompatible_element
:description: a bin set expression yields an array whose element type is not assignment compatible with the coverpoint (IEEE 1800-2023 Section 19.5.1.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin set expression of the coverpoint is an array of string, whose element type is not assignment compatible with the integral coverpoint
:expected_stderr_regex: test_illegal_cg_bin_set_incompatible_element\.sv:28:
*/
// A bin set expression shall yield a non-associative array whose element type
// is assignment compatible with the coverpoint. The coverpoint below is the
// 4-bit vector v, and its bin set expression is an array of string, which is
// the error. Icarus Verilog 13.0 does not implement covergroups, and release
// 5.052 of the Verilator tool rejects every bin set expression of this form as
// a construct it does not support, so neither diagnostic is evidence for this
// rule.

module test_illegal_cg_bin_set_incompatible_element;
  bit [3:0] v;
  string svals[2];

  covergroup cg;
    cp: coverpoint v {
      bins b = svals;   // illegal: string elements for an integral point
    }
  endgroup

  cg g = new;

  initial begin
    svals[0] = "a";
    svals[1] = "b";
    v = 0;
    g.sample();
  end
endmodule
