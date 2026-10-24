/*
:name: test_illegal_assertion_function_keeps_state
:description: a function in an expression of a concurrent assertion has to be automatic or keep no state (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a_bad calls the static function f_count, whose static local variable n keeps a count from call to call
:expected_stderr_regex: test_illegal_assertion_function_keeps_state\.sv:40:
*/
// IEEE 1800-2023 §16.6: functions that appear in expressions of concurrent
// assertions shall be automatic or preserve no state information, and shall
// have no side effects. f_auto counts in its local n, which is automatic
// and so starts again at each call, and f_pure is static but has no local
// state; a_auto and a_pure are legal. f_count is static, so its local n
// keeps its value between calls, and a_bad calls it.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_assertion_function_keeps_state;
  logic clk = 0, a = 0;
  function automatic bit f_auto(bit x);
    int n = 0;
    n = n + 1;
    return x && n == 1;
  endfunction
  function bit f_pure(bit x);
    return !x;
  endfunction
  function bit f_count(bit x);
    static int n = 0;
    n = n + 1;
    return x && n > 0;
  endfunction
  a_auto: assert property (@(posedge clk) f_auto(a));
  a_pure: assert property (@(posedge clk) f_pure(a));
  a_bad: assert property (@(posedge clk) f_count(a));   // illegal
endmodule
