/*
:name: test_illegal_cg_ref_formal_variable
:description: a covergroup expression uses a ref argument instead of a non-ref one (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the coverpoint expression uses v, a ref argument of the covergroup
:expected_stderr_regex: test_illegal_cg_ref_formal_variable\.sv:26:
*/
// Only constant expressions, the permitted constants and non-ref
// arguments to the covergroup may be used as variables in a covergroup
// expression. A ref argument is not a non-ref argument.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_ref_formal_variable;
  class c;
    covergroup cg(ref int v);
      coverpoint v;   // illegal: v is a ref argument
    endgroup
  endclass
endmodule
