/*
:name: test_illegal_named_parameter_assigned_twice
:description: Once a parameter is assigned by name in a parameter value assignment, it cannot be assigned again in the same list, while an empty pair of parentheses leaves a parameter at its default (IEEE 1800-2023 Section 23.10.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parameter value assignment of u2 assigns W by name twice
:expected_stderr_regex: test_illegal_named_parameter_assigned_twice\.sv:(29|30):
*/
// IEEE 1800-2023 §23.10.2.2: in a parameter assignment by name the expression
// is optional, and with empty parentheses the parameter keeps its default
// value; once a parameter is assigned a value, there shall not be another
// assignment to that parameter name. u1 names D with empty parentheses and
// assigns W, which is legal; u2 assigns W twice, the second time on the
// continuation line, and a tool can report it there or at the start of the
// instantiation.
// Icarus Verilog 13.0 accepts the design.

module npt_leaf #(parameter int W = 4, parameter int D = 2) ();
  initial #1 $display("%m W=%0d D=%0d", W, D);
endmodule

module test_illegal_named_parameter_assigned_twice;
  npt_leaf #(.D(), .W(8)) u1 ();
  npt_leaf #(.W(8), .D(3),
             .W(16)) u2 ();   // illegal: W is assigned a second time
endmodule
