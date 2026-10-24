/*
:name: test_illegal_global_clock_future_function_in_procedure
:description: a global clocking future sampled value function cannot be used in procedural code, unlike a past one (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always procedure assigns the result of $future_gclk to y
:expected_stderr_regex: test_illegal_global_clock_future_function_in_procedure\.sv:29:
*/
// IEEE 1800-2023 §16.9.4: the global clocking future sampled value functions
// may be used only in a property_expr or a sequence_expr, so not in action
// blocks; they shall not be nested, and shall not be used in assertions that
// contain sequence match items. The module declares global clocking.
// The past functions may be used in procedural code: the procedure assigns
// $past_gclk(a) to x, which is legal, and then $future_gclk(a) to y.
// Icarus Verilog 13.0 does not support global clocking; the syntax errors it
// reports do not count.

module test_illegal_global_clock_future_function_in_procedure;
  logic clk = 0, a = 0, b = 0;
  global clocking gc @(posedge clk); endclocking
  logic x, y;
  always @(posedge clk) begin
    x = $past_gclk(a);
    y = $future_gclk(a);   // illegal
  end
endmodule
