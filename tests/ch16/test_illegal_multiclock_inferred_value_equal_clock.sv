/*
:name: test_illegal_multiclock_inferred_value_equal_clock
:description: in an always procedure whose inferred clock is posedge clk1, a property that adds a leading clock on posedge clk2, where clk2 is continuously assigned from clk1, has no unique semantic leading clock and cannot be asserted (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.16.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a_bad has the inferred clock posedge clk1 for a and the clock posedge clk2 for b as its leading clocks; clk2 always has the value of clk1, but the two clocking events are not identical, so the asserted property has no unique semantic leading clock
:expected_stderr_regex: test_illegal_multiclock_inferred_value_equal_clock\.sv:38:
*/
// IEEE 1800-2023 §16.16.1: a clocking event inferred from the procedural
// context is treated as if it were written as the leading clock of the
// assertion (16.16), so a and @(posedge clkX) b in an always procedure on
// posedge clk1 has the leading clocks posedge clk1 and posedge clkX. Such a
// multiclocked property has a unique semantic leading clock only when they are
// identical, and clocking events on different signals are not identical even
// when the signals always have the same value.
// clk2 is continuously assigned from clk1. The procedure has one event
// control, posedge clk1, and clk1 appears elsewhere in it only as a clocking
// event, so posedge clk1 is inferred for its assertions (16.14.6). a_same adds
// posedge clk1 again, so both of its leading clocks are identical, and 16.16.1
// names this form as legal; a_bad adds posedge clk2, which is the only error.
// Icarus Verilog 13.0 and the 5.054 release of Verilator do not support
// multiclocked properties and report syntax errors on the legal assertion
// too, so neither error counts.

module test_illegal_multiclock_inferred_value_equal_clock;
  logic clk1 = 1'b0, a = 1'b0, b = 1'b0;
  wire clk2;

  assign clk2 = clk1;

  always @(posedge clk1) begin
    a_same: assert property (a and @(posedge clk1) b);
    a_bad: assert property (a and @(posedge clk2) b);   // illegal
  end
endmodule
