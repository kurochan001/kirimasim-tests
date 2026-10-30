/*
:name: test_illegal_cg_outer_constant
:description: a covergroup expression references a package constant outside its class (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the bin b of coverpoint v uses p::OUTER, a constant that is not a member of the enclosing class
:expected_stderr_regex: test_illegal_cg_outer_constant\.sv:35:
*/
// Global and instance constants referenced from a covergroup expression
// shall be members of the enclosing class. Here the expression names a
// package constant instead; a const variable is not a constant expression
// (11.2.1), so no other rule allows it.
// The restriction is on covergroup_expression, which the syntax of 19.5
// uses for the values of bins and not for the expression after the
// coverpoint keyword, so the constant is used in the value of a bin.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

package p;
  const int OUTER = 3;
endpackage
module test_illegal_cg_outer_constant;
  class c;
    int v;
    covergroup cg;
      coverpoint v {
        bins b = {p::OUTER};   // illegal: not an enclosing-class member
      }
    endgroup
  endclass
endmodule
