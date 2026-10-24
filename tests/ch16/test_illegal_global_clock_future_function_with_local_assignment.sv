/*
:name: test_illegal_global_clock_future_function_with_local_assignment
:description: a global clocking future sampled value function cannot be used in an assertion with a sequence match item (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property of a_bad has the match item k = 1 and calls $future_gclk
:expected_stderr_regex: test_illegal_global_clock_future_function_with_local_assignment\.sv:(34|38):
*/
// IEEE 1800-2023 §16.9.4: the global clocking future sampled value functions
// may be used only in a property_expr or a sequence_expr, so not in action
// blocks; they shall not be nested, and shall not be used in assertions that
// contain sequence match items. The module declares global clocking.
// p_loc has a match item that assigns its local variable k, and a_fut calls
// $future_gclk without match items; both are legal. p_bad has both. A tool
// can report the error in p_bad or at its assertion a_bad.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support @$global_clock as the clock of an assertion;
// neither error counts.

module test_illegal_global_clock_future_function_with_local_assignment;
  logic clk = 0, a = 0, b = 0;
  global clocking gc @(posedge clk); endclocking
  property p_loc;
    int k;
    (a, k = 1) |-> k == 1;
  endproperty
  property p_bad;
    int k;
    (a, k = 1) |-> $future_gclk(b);   // illegal
  endproperty
  a_loc: assert property (@$global_clock p_loc);
  a_fut: assert property (@$global_clock a |-> $future_gclk(b));
  a_bad: assert property (@$global_clock p_bad);
endmodule
