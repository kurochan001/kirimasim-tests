/*
:name: test_illegal_sampled_function_in_disable_condition_unclocked
:description: a sampled value function in a disable condition has to be given its clocking event explicitly (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable condition of a_bad calls $rose without a clocking event
:expected_stderr_regex: test_illegal_sampled_function_in_disable_condition_unclocked\.sv:30:
*/
// IEEE 1800-2023 §16.9.3: a sampled value function other than $sampled needs
// a clocking event, given as an argument or inferred: in an assertion from
// the clock flow, in an action block from the leading clock, in a procedure
// from the procedural context, and elsewhere from default clocking. In a
// disable condition or a clock expression it shall be given explicitly.
// a_ok calls $rose(rst, @(posedge clk)) in its disable condition, and a_body
// calls $rose(a) without a clock in its property, where the clock flows in;
// both are legal. a_bad calls $rose(rst) in its disable condition.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support the clocking event argument of $rose; neither error
// counts.

module test_illegal_sampled_function_in_disable_condition_unclocked;
  logic clk = 0, rst = 0, a = 0, b = 0;
  a_ok: assert property (@(posedge clk) disable iff ($rose(rst, @(posedge clk))) a |=> b);
  a_body: assert property (@(posedge clk) $rose(a) |=> b);
  a_bad: assert property (@(posedge clk) disable iff ($rose(rst)) a |=> b);   // illegal
endmodule
