/*
:name: test_illegal_assignment_operator_in_event_expression
:description: an assignment operator cannot be used in an event expression (IEEE 1800-2023 Section 11.3.6)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.3.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the event control @((a = b)) contains the assignment a = b
:expected_stderr_regex: test_illegal_assignment_operator_in_event_expression\.sv:34:
*/
// IEEE 1800-2023 §11.3.6: it shall be illegal to include an assignment
// operator in an event expression. The event control @(a or b) and the
// parenthesized assignment c = (a = b) in a procedural statement are legal;
// the event control @((a = b)) contains an assignment.
// Icarus Verilog 13.0 gives syntax errors also on the legal assignments in
// expressions, so its error does not count.
// The design is accepted by the 5.052 release of Verilator.

`timescale 1ns/1ns

module test_illegal_assignment_operator_in_event_expression;
  int a, b, c;

  initial begin
    #1 b = 4;
    #1 c = (a = b);
  end

  initial begin
    @(a or b);
    @((a = b));   // illegal: an assignment in an event expression
    $display("%0d", c);
  end
endmodule
