/*
:name: test_illegal_cg_function_side_effect
:description: a function called from a covergroup expression changes a variable (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f increments the class member calls, so it has a side effect
:expected_stderr_regex: test_illegal_cg_function_side_effect\.sv:31:
*/
// A function used in a covergroup expression shall be automatic or keep
// no state, shall have no side effects and shall not reference
// nonconstant variables outside its local scope. f writes calls.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_function_side_effect;
  class c;
    static int calls = 0;
    static function int f(int a);
      calls = calls + 1;
      return a;
    endfunction
    covergroup cg;
      coverpoint f(1);   // illegal: f has a side effect
    endgroup
  endclass
endmodule
