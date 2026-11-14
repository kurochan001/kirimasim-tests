/*
:name: test_illegal_let_event_formal_outside_event_expression
:description: a formal argument of type event of a let can be referenced only where an event expression can be written (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the event formal ev of the let level is referenced as an operand of &&, where an event expression cannot be written
:expected_stderr_regex: test_illegal_let_event_formal_outside_event_expression\.sv:(34|38):
*/
// IEEE 1800-2023 §11.12: when a formal argument of a let is of type event,
// its actual argument shall be an event expression and every reference to
// the formal shall be in a place where an event expression may be written.
// In rose_on the formal ev is referenced in the clocking event @(ev) of
// $rose (§16.9.3), a place for an event expression, and the actual clk is an
// event expression, so rose_on(a, clk) is legal. In level the formal ev is
// an operand of &&, where only an expression can be written. A tool can
// report the error at the declaration (line 34) or where level is used
// (line 38).
// Icarus Verilog 13.0 does not support let declarations, and the 5.054
// release of Verilator reports typed let ports as unsupported and does not
// parse the clocking event in the let body; none of these errors is the
// diagnostic of this rule.

module test_illegal_let_event_formal_outside_event_expression;
  logic clk = 1'b0;
  logic a = 1'b0;
  bit r, q;

  let rose_on(x, event ev) = $rose(x, @(ev));
  let level(event ev) = ev && 1'b1;   // illegal: an event formal as an operand

  initial begin
    r = rose_on(a, clk);
    q = level(clk);
  end
endmodule
