/*
:name: test_illegal_assignment_operator_in_procedural_assign
:description: an assignment operator cannot be used in an expression of a procedural continuous assignment (IEEE 1800-2023 Section 11.3.6)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.3.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the right-hand side of the procedural continuous assignment to v contains the assignment a = b
:expected_stderr_regex: test_illegal_assignment_operator_in_procedural_assign\.sv:29:
*/
// IEEE 1800-2023 §11.3.6: it shall be illegal to include an assignment
// operator in an expression within a procedural continuous assignment
// (10.6). The procedural continuous assignment assign v = a + b and the
// parenthesized assignment c = (a = b) in a procedural statement are legal;
// assign v = (a = b) contains an assignment.
// Icarus Verilog 13.0 gives syntax errors also on the legal assignments in
// expressions, so its error does not count.
// The design is accepted by the 5.052 release of Verilator.

module test_illegal_assignment_operator_in_procedural_assign;
  int a, b = 6, c, v;

  initial begin
    assign v = a + b;
    c = (a = b);
    assign v = (a = b);   // illegal: an assignment in a procedural continuous assignment
    $display("%0d %0d", c, v);
  end
endmodule
