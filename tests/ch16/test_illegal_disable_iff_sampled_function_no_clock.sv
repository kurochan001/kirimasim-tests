/*
:name: test_illegal_disable_iff_sampled_function_no_clock
:description: A sampled value function other than $sampled in a disable condition needs an explicit clock (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable condition calls $rose without a clocking event argument
:expected_stderr_regex: test_illegal_disable_iff_sampled_function_no_clock\.sv:25:
*/
// IEEE 1800-2023 §16.12: if a sampled value function other than $sampled is
// used in the disable condition, its clock shall be given explicitly as an
// argument (§16.9.3). The disable condition calls $rose(r1) without one;
// $rose(r1, @(posedge clk)) would be legal.
// Icarus Verilog 13.0 does not support concurrent assertions, so the errors
// it reports here do not count.

module test_illegal_disable_iff_sampled_function_no_clock;
  logic clk, clk2, a, b, r1, r2;
  int d, k;

  a_rose: assert property (@(posedge clk) disable iff ($rose(r1)) a |=> b);   // illegal
endmodule
