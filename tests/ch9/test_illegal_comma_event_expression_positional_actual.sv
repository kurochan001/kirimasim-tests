/*
:name: test_illegal_comma_event_expression_positional_actual
:description: an event expression with comma-separated parts passed as a positional actual argument needs parentheses around it (IEEE 1800-2023 Section 9.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.4 16.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the comma-separated event expression posedge clk, negedge clk is passed to the sequence s_ev by position without parentheses
:expected_stderr_regex: test_illegal_comma_event_expression_positional_actual\.sv:31:
*/
// IEEE 1800-2023 §9.4: parentheses are required when an event expression that
// contains comma-separated event expressions is passed as an actual argument
// using positional binding. s_ev has two formal arguments, the event ev and
// x. In the first assertion the event expression is in parentheses and is
// the first of two actual arguments; in the second it is not, so its comma
// separates arguments and s_ev gets three.
// Icarus Verilog 13.0 does not support sequences, and Verilator 5.052 gives a
// syntax error also on the legal assertion ok_a, so neither error counts.

module test_illegal_comma_event_expression_positional_actual;
  logic clk = 1'b0, a = 1'b1;

  sequence s_ev(event ev, x);
    @(ev) x;
  endsequence

  ok_a: assert property (s_ev((posedge clk, negedge clk), a));
  bad_a: assert property (s_ev(posedge clk, negedge clk, a));   // illegal: needs parentheses

  initial #1 $display("done");
endmodule
