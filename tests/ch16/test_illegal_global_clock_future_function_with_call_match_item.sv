/*
:name: test_illegal_global_clock_future_function_with_call_match_item
:description: a global clocking future sampled value function cannot be used in an assertion with a subroutine call match item (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property of a_bad has the subroutine call match item note() and calls $rising_gclk
:expected_stderr_regex: test_illegal_global_clock_future_function_with_call_match_item\.sv:33:
*/
// IEEE 1800-2023 §16.9.4: the global clocking future sampled value functions
// may be used only in a property_expr or a sequence_expr, so not in action
// blocks; they shall not be nested, and shall not be used in assertions that
// contain sequence match items. The module declares global clocking.
// A subroutine call attached to a sequence is a sequence match item too
// (16.11). a_call has such a match item and a_fut calls $rising_gclk without
// one; both are legal. a_bad has both.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support @$global_clock as the clock of an assertion;
// neither error counts.

module test_illegal_global_clock_future_function_with_call_match_item;
  logic clk = 0, a = 0, b = 0;
  global clocking gc @(posedge clk); endclocking
  function void note();
    $display("note");
  endfunction
  a_call: assert property (@$global_clock (a, note()) |-> b);
  a_fut: assert property (@$global_clock a |-> $rising_gclk(b));
  a_bad: assert property (@$global_clock (a, note()) |-> $rising_gclk(b));   // illegal
endmodule
