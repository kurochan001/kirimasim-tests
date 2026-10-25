/*
:name: test_illegal_defparam_rhs_variable
:description: The right-hand side of a defparam assignment has to be a constant expression, so it cannot read a variable (IEEE 1800-2023 Section 23.10.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the right-hand side of the defparam reads the variable v, which is not a constant expression
:expected_stderr_regex: test_illegal_defparam_rhs_variable\.sv:26:
*/
// IEEE 1800-2023 §23.10.1: the right-hand side of a defparam assignment
// shall be a constant expression of numbers and of parameters declared in
// the module of the defparam. v is a variable of that module, not a
// parameter, so v + 1 is not such an expression.

module defparam_rhs_variable_leaf;
  parameter int P = 0;
endmodule

module test_illegal_defparam_rhs_variable;
  int v = 4;
  defparam_rhs_variable_leaf u();
  defparam u.P = v + 1;   // illegal
endmodule
