/*
:name: test_illegal_assignment_operator_in_continuous_assign
:description: an assignment operator cannot be used in an expression that is not within a procedural statement, such as the right-hand side of a continuous assignment (IEEE 1800-2023 Section 11.3.6)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.3.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the right-hand side of the continuous assignment to w contains the assignment a = b
:expected_stderr_regex: test_illegal_assignment_operator_in_continuous_assign\.sv:29:
*/
// IEEE 1800-2023 §11.3.6: it shall be illegal to include an assignment
// operator in an expression that is not within a procedural statement. A
// continuous assignment is not a procedural statement. assign w = a + b and
// the parenthesized assignment c = (a = b) in an initial procedure are legal;
// assign w = (a = b) contains an assignment.
// Icarus Verilog 13.0 gives syntax errors also on the legal assignments in
// expressions, so its error does not count.
// The 5.052 release of Verilator takes the assignment as a continuous
// driver of a and reports the legal procedural assignment to a instead.

module test_illegal_assignment_operator_in_continuous_assign;
  int a, b = 6, c;
  wire [31:0] w, w2;

  assign w2 = a + b;
  assign w = (a = b);   // illegal: an assignment outside a procedural statement

  initial begin
    c = (a = b);
    #1 $display("%0d %0d", c, w2);
  end
endmodule
