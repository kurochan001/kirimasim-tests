/*
:name: test_illegal_global_clock_future_functions_nested
:description: global clocking future sampled value functions cannot be nested (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the argument of $steady_gclk in a_bad calls $falling_gclk
:expected_stderr_regex: test_illegal_global_clock_future_functions_nested\.sv:28:
*/
// IEEE 1800-2023 §16.9.4: the global clocking future sampled value functions
// may be used only in a property_expr or a sequence_expr, so not in action
// blocks; they shall not be nested, and shall not be used in assertions that
// contain sequence match items. The module declares global clocking.
// a_ok calls $steady_gclk and $falling_gclk side by side; a_bad calls
// $falling_gclk inside the argument of $steady_gclk.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support @$global_clock as the clock of an assertion;
// neither error counts.

module test_illegal_global_clock_future_functions_nested;
  logic clk = 0, a = 0, b = 0;
  global clocking gc @(posedge clk); endclocking
  a_ok: assert property (@$global_clock $steady_gclk(a) || $falling_gclk(b));
  a_bad: assert property (@$global_clock $steady_gclk(a && $falling_gclk(b)));   // illegal
endmodule
