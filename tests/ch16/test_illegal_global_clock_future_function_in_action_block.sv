/*
:name: test_illegal_global_clock_future_function_in_action_block
:description: a global clocking future sampled value function cannot be used in an action block, unlike a past one (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the fail action of a_bad calls $future_gclk
:expected_stderr_regex: test_illegal_global_clock_future_function_in_action_block\.sv:28:
*/
// IEEE 1800-2023 §16.9.4: the global clocking future sampled value functions
// may be used only in a property_expr or a sequence_expr, so not in action
// blocks; they shall not be nested, and shall not be used in assertions that
// contain sequence match items. The module declares global clocking.
// The past functions may be used in action blocks: a_ok prints $past_gclk(a)
// in its fail action; a_bad prints $future_gclk(a) there.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support @$global_clock as the clock of an assertion;
// neither error counts.

module test_illegal_global_clock_future_function_in_action_block;
  logic clk = 0, a = 0, b = 0;
  global clocking gc @(posedge clk); endclocking
  a_ok: assert property (@$global_clock a) else $display("%b", $past_gclk(a));
  a_bad: assert property (@$global_clock a) else $display("%b", $future_gclk(a));   // illegal
endmodule
