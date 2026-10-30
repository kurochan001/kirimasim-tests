/*
:name: test_illegal_cg_system_function
:description: a covergroup expression calls a system function that is not constant (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the bin b of coverpoint v calls $urandom, which is not a constant system function call
:expected_stderr_regex: test_illegal_cg_system_function\.sv:30:
*/
// System function calls in a covergroup expression are restricted to
// constant system function calls. $urandom returns a new value each
// time, so it is not constant.
// The restriction is on covergroup_expression, which the syntax of 19.5
// uses for the values of bins and not for the expression after the
// coverpoint keyword, so the call is made in the value of a bin.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_system_function;
  int v;
  covergroup cg;
    coverpoint v {
      bins b = {$urandom};   // illegal: not a constant system function
    }
  endgroup
endmodule
