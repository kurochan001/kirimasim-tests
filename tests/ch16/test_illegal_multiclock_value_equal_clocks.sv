/*
:name: test_illegal_multiclock_value_equal_clocks
:description: clocking events on two different signals are not identical even when one signal is continuously assigned from the other, so a property whose two leading clocks are such events has no unique semantic leading clock and cannot be asserted (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.16.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the two operands of and in a_bad start on posedge clk1 and on posedge clk2; clk2 always has the value of clk1, but the clocking events are not identical, so the asserted property has no unique semantic leading clock
:expected_stderr_regex: test_illegal_multiclock_value_equal_clocks\.sv:35:
*/
// IEEE 1800-2023 §16.16.1: the set of semantic leading clocks of q1 and q2 is
// the union of those of q1 and q2, and a multiclocked property has a unique
// semantic leading clock when all its leading clocks are identical. Two
// clocking events on different signals are not identical, even when the
// signals always have the same value. The maximal property of a concurrent
// assertion shall have a unique semantic leading clock (16.16).
// clk2 is continuously assigned from clk1. a_same and a_two_same each have
// two identical leading clocks and are legal; a_bad has posedge clk1 and
// posedge clk2 as its leading clocks, which is the only error.
// Icarus Verilog 13.0 and the 5.054 release of Verilator do not support
// multiclocked properties and report syntax errors on the legal assertions
// too, so neither error counts.

module test_illegal_multiclock_value_equal_clocks;
  logic clk1 = 1'b0, a = 1'b0, b = 1'b0;
  wire clk2;

  assign clk2 = clk1;

  a_same: assert property (@(posedge clk1) a and @(posedge clk1) b);
  a_two_same: assert property (@(posedge clk2) a and @(posedge clk2) b);
  a_bad: assert property (@(posedge clk1) a and @(posedge clk2) b);   // illegal
endmodule
