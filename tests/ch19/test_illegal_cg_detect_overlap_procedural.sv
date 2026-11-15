/*
:name: test_illegal_cg_detect_overlap_procedural
:description: the detect_overlap option of a covergroup instance is assigned procedurally after the instance is built (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial block assigns option.detect_overlap of the instance g after its construction
:expected_stderr_regex: test_illegal_cg_detect_overlap_procedural\.sv:42:
*/
// IEEE 1800-2023 §19.7: option assignments in the covergroup definition are
// evaluated when the covergroup is instantiated. The auto_bin_max,
// detect_overlap and cross_retain_auto_bins options can only be set in the
// definition of the covergroup or a coverpoint, not by a procedural assignment
// after the instance is made. Other instance options, such as comment, can be
// assigned procedurally after the instance is made. The definition of cg sets
// detect_overlap at the covergroup level, which Table 19-2 allows, and the
// initial block assigns the comment of g, which is legal; the assignment to
// g.option.detect_overlap after new is the one error. Without that line the
// design is legal.
//
// Icarus Verilog 13.0 does not implement covergroups, and the 5.054
// release of Verilator accepts the assignment, so the cited clause alone
// decides this test.

module test_illegal_cg_detect_overlap_procedural;
  bit [1:0] a, b;

  covergroup cg;
    option.detect_overlap = 1;
    ca: coverpoint a;
  endgroup

  cg g;

  initial begin
    g = new;
    g.option.comment = "set after new";
    g.option.detect_overlap = 0;   // illegal: after construction
  end
endmodule
