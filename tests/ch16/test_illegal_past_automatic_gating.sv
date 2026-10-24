/*
:name: test_illegal_past_automatic_gating
:description: an automatic variable cannot be the gating expression of $past (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the gating expression of the second $past is the automatic variable g
:expected_stderr_regex: test_illegal_past_automatic_gating\.sv:30:
*/
// IEEE 1800-2023 §16.9.3: it shall be illegal to use automatic variables in
// the clocking events and in the gating expression expression2 of $past.
// Both calls are in an always procedure clocked by posedge clk, from which
// their clock may be inferred (16.14.6).
// The first $past is gated with the static variable en; the second with the
// automatic variable g of the procedure.
// Icarus Verilog 13.0 does not support automatic variables in a static
// procedure, and Verilator 5.052 does not support the gating and clocking
// event arguments of $past; neither error counts.

module test_illegal_past_automatic_gating;
  logic clk = 0, en = 0, d = 0;
  logic q1, q2;
  always @(posedge clk) begin
    automatic logic g = en;
    q1 <= $past(d, 1, en);
    q2 <= $past(d, 1, g);   // illegal
  end
endmodule
