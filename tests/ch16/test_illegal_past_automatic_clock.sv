/*
:name: test_illegal_past_automatic_clock
:description: an automatic variable cannot be used in the clocking event of $past (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the clocking event of the second $past uses the automatic variable g
:expected_stderr_regex: test_illegal_past_automatic_clock\.sv:31:
*/
// IEEE 1800-2023 §16.9.3: it shall be illegal to use automatic variables in
// the clocking events and in the gating expression expression2 of $past.
// Both calls are in an always procedure clocked by posedge clk, from which
// their clock may be inferred (16.14.6).
// The first $past has the clocking event @(posedge clk) of the static
// variable clk; the second has @(posedge g), with the automatic variable g of
// the procedure.
// Icarus Verilog 13.0 does not support automatic variables in a static
// procedure, and Verilator 5.052 does not support the gating and clocking
// event arguments of $past; neither error counts.

module test_illegal_past_automatic_clock;
  logic clk = 0, en = 0, d = 0;
  logic q1, q2;
  always @(posedge clk) begin
    automatic logic g = en;
    q1 <= $past(d, 1, , @(posedge clk));
    q2 <= $past(d, 1, , @(posedge g));   // illegal
  end
endmodule
