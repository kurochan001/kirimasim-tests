/*
:name: test_illegal_assignment_in_expression_without_parentheses
:description: a blocking assignment used inside an expression has to be enclosed in its own parentheses (IEEE 1800-2023 Section 11.3.6)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.3.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the condition of the if statement is the assignment a = b without parentheses of its own
:expected_stderr_regex: test_illegal_assignment_in_expression_without_parentheses\.sv:28:
*/
// IEEE 1800-2023 §11.3.6: an expression can include a blocking assignment
// without a timing control, but such an assignment shall be enclosed in
// parentheses, so that a = b is not mistaken for a == b. if ((a = b)) and
// c = (a = 5) are legal; in if (a = b) the parentheses belong to the if
// statement, and the assignment has none of its own.
// Icarus Verilog 13.0 gives syntax errors also on the legal assignments in
// expressions, so its error does not count.

module test_illegal_assignment_in_expression_without_parentheses;
  int a, b = 2, c;

  initial begin
    if ((a = b)) c = 1;
    c = (a = 5);
    if (a = b) c = 2;   // illegal: the assignment is not in parentheses
    $display("%0d %0d", a, c);
  end
endmodule
