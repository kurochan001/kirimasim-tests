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
:should_fail_because: the coverpoint expression uses p::OUTER, a constant that is not a member of the enclosing class
:expected_stderr_regex: test_illegal_cg_outer_constant\.sv:29:
*/
// Global and instance constants referenced from a covergroup expression
// shall be members of the enclosing class. Here the expression names a
// package constant instead.
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
    covergroup cg;
      coverpoint p::OUTER;   // illegal: not an enclosing-class member
    endgroup
  endclass
endmodule
