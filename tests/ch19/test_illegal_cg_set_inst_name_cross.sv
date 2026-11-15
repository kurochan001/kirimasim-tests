/*
:name: test_illegal_cg_set_inst_name_cross
:description: set_inst_name, which Table 19-5 provides only for a covergroup, is called on a cross of a covergroup instance (IEEE 1800-2023 Section 19.8)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.8
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: Table 19-5 provides set_inst_name for a covergroup and not for a cross, so the call of set_inst_name on cross x of the instance g is an error
:expected_stderr_regex: test_illegal_cg_set_inst_name_cross\.sv:43:
*/
// IEEE 1800-2023 §19.8: Table 19-5 says on which items each predefined
// coverage method can be called. set_inst_name can be called on a
// covergroup only, while get_inst_coverage can also be called on a
// coverpoint or a cross. The design calls set_inst_name on the instance g
// and get_inst_coverage on its cross x, which are legal, and then
// set_inst_name on x, the one error, which a tool has to report at that
// call.
//
// Icarus Verilog 13.0 does not implement covergroups and rejects the
// declaration of cg with syntax errors, not the call. The 5.054 release
// of Verilator reports at that call that x has no method set_inst_name,
// the error it also gives for a name such as foo that is no method at all,
// and it accepts the legal calls before it.

module test_illegal_cg_set_inst_name_cross;
  bit [1:0] a, b;
  real r;

  covergroup cg;
    cp: coverpoint a;
    cq: coverpoint b;
    x: cross cp, cq;
  endgroup

  cg g = new;

  initial begin
    g.set_inst_name("whole");
    r = g.x.get_inst_coverage();
    g.x.set_inst_name("product");  // illegal
  end
endmodule
