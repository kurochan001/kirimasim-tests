/*
:name: test_illegal_cg_per_instance_after_new
:description: the per_instance option of a covergroup instance is assigned procedurally after the instance is built (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial block assigns option.per_instance of the instance g after its construction
:expected_stderr_regex: test_illegal_cg_per_instance_after_new\.sv:41:
*/
// IEEE 1800-2023 §19.7: option assignments in the covergroup definition are
// evaluated when the covergroup is instantiated. The per_instance and
// get_inst_coverage options can only be set there, not by a procedural
// assignment after the instance is made. Other instance options, such as
// comment, can be assigned procedurally after the instance is made. The
// definition of cg sets per_instance at the covergroup level, which Table
// 19-2 allows, and the initial block assigns the comment of g, which is legal;
// the assignment to g.option.per_instance after new is the one error.
// Without that line the design is legal.
//
// Icarus Verilog 13.0 does not implement covergroups, and the 5.054
// release of Verilator accepts the assignment, so the cited clause alone
// decides this test.

module test_illegal_cg_per_instance_after_new;
  bit [1:0] a, b;

  covergroup cg;
    option.per_instance = 1;
    ca: coverpoint a;
  endgroup

  cg g;

  initial begin
    g = new;
    g.option.comment = "set after new";
    g.option.per_instance = 0;   // illegal: after construction
  end
endmodule
