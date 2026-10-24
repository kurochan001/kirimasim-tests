/*
:name: test_illegal_event_compare_relational_operator
:description: an event variable cannot be an operand of a relational operator (IEEE 1800-2023 Section 15.5.5.3)
:tags: ch15
:type: elaboration
:lrm: 1800-2023 15.5.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the last if compares the events e1 and e2 with the relational operator <
:expected_stderr_regex: test_illegal_event_compare_relational_operator\.sv:31:
*/
// IEEE 1800-2023 §15.5.5.3: an event variable can be compared only with
// another event variable or null, with ==, !=, === and !== (the last two
// with the same meaning as the first two), or tested as a Boolean value.
// The initial procedure uses each of these forms, which are legal;
// the last if compares e1 and e2 with <.
// Icarus Verilog 13.0 rejects the legal comparisons of an event with null,
// and Verilator 5.052 accepts the design.

module test_illegal_event_compare_relational_operator;
  event e1, e2;
  int n = 0;
  initial begin
    if (e1 == e2) $display("eq");
    if (e1 != null) $display("ne null");
    if (e1 === e2) $display("case eq");
    if (e2 !== null) $display("case ne null");
    if (e1) $display("not null");
    if (e1 < e2) $display("less");   // illegal
  end
endmodule
