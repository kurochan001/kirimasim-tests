/*
:name: test_illegal_cg_per_instance_procedural
:description: the per_instance option is set after the covergroup instance is built (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial block assigns per_instance through the covergroup variable of obj, after construction
:expected_stderr_regex: test_illegal_cg_per_instance_procedural\.sv:32:
*/
// The per_instance and get_inst_coverage options can only be set in the
// covergroup definition. A procedural assignment through an instance
// after construction is an error.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_per_instance_procedural;
  class c;
    covergroup cg(input int v);
      coverpoint v;
    endgroup
  endclass
  c obj;
  initial begin
    obj = new;
    obj.cg.option.per_instance = 1;   // illegal: after construction
  end
endmodule
