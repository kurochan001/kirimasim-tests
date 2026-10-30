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
:should_fail_because: the bound of the bin b uses hi, a ref argument of the covergroup
:expected_stderr_regex: test_illegal_cg_ref_formal_variable\.sv:32:
*/
// Only constant expressions, the permitted constants and non-ref
// arguments to the covergroup may be used as variables in a covergroup
// expression. A ref argument is not a non-ref argument.
// The syntax of 19.5 uses covergroup_expression for the values of bins,
// not for the expression after the coverpoint keyword, which may cover a
// ref argument. So coverpoint v is legal, and only the bound of the bin b,
// which uses the ref argument hi as a variable, is the error. The bound
// does not use v, which here is also the name of the coverpoint.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_ref_formal_variable;
  class c;
    covergroup cg(ref int v, ref int hi);
      coverpoint v {
        bins b = {[0:hi]};   // illegal: hi is a ref argument
      }
    endgroup
  endclass
endmodule
