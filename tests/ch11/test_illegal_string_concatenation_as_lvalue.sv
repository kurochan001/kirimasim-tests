/*
:name: test_illegal_string_concatenation_as_lvalue
:description: a concatenation of strings is only an expression and cannot be the left-hand side of an assignment (IEEE 1800-2023 Section 11.4.12.2)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the left-hand side of the assignment is the concatenation {s1, s2} of two strings
:expected_stderr_regex: test_illegal_string_concatenation_as_lvalue\.sv:26:
*/
// IEEE 1800-2023 §11.4.12.2: if an operand of a concatenation is a string, the
// concatenation is a string; string concatenation is not allowed on the
// left-hand side of an assignment, only as an expression. s = {s1, " ", s2}
// is legal; {s1, s2} = s is not.
// Icarus Verilog 13.0 stops with a failed assertion, and the design is
// accepted by the 5.052 release of Verilator.

module test_illegal_string_concatenation_as_lvalue;
  string s1 = "ab", s2 = "cd", s;

  initial begin
    s = {s1, " ", s2};
    {s1, s2} = s;   // illegal: a string concatenation as a left-hand side
    $display("%s", s);
  end
endmodule
