/*
:name: test_illegal_assignment_in_expression_with_delay
:description: a blocking assignment used inside an expression cannot have a timing control (IEEE 1800-2023 Section 11.3.6)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.3.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assignment b = #1 a inside the expression has an intra-assignment delay
:expected_stderr_regex: test_illegal_assignment_in_expression_with_delay\.sv:27:
*/
// IEEE 1800-2023 §11.3.6: an expression can include a blocking assignment,
// provided that the assignment does not have a timing control. c = (b = a)
// is legal, and so is the statement b = #1 a; the assignment with the delay
// inside the expression c = (b = #1 a) is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal assignments in
// expressions, so its error does not count.

module test_illegal_assignment_in_expression_with_delay;
  int a = 3, b, c;

  initial begin
    c = (b = a);
    b = #1 a;
    c = (b = #1 a);   // illegal: timing control in an assignment in an expression
    $display("%0d %0d", b, c);
  end
endmodule
