/*
:name: test_illegal_sampled_function_in_clock_expression_unclocked
:description: a sampled value function in the clock expression of an assertion has to be given its clocking event explicitly (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the clocking event of a_bad calls $stable without a clocking event of its own
:expected_stderr_regex: test_illegal_sampled_function_in_clock_expression_unclocked\.sv:28:
*/
// IEEE 1800-2023 §16.9.3: a sampled value function other than $sampled needs
// a clocking event, given as an argument or inferred: in an assertion from
// the clock flow, in an action block from the leading clock, in a procedure
// from the procedural context, and elsewhere from default clocking. In a
// disable condition or a clock expression it shall be given explicitly.
// a_ok gates its clock with $stable(en, @(posedge clk)); a_bad gates it with
// $stable(en), which has no clocking event of its own.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support the clocking event argument of $stable; neither
// error counts.

module test_illegal_sampled_function_in_clock_expression_unclocked;
  logic clk = 0, en = 0, a = 0, b = 0;
  a_ok: assert property (@(posedge clk iff $stable(en, @(posedge clk))) a |=> b);
  a_bad: assert property (@(posedge clk iff $stable(en)) a |=> b);   // illegal
endmodule
