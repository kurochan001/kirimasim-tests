/*
:name: test_illegal_defparam_rhs_other_module_parameter
:description: The parameters on the right-hand side of a defparam assignment have to be declared in the module of the defparam, so it cannot use a parameter of another instance (IEEE 1800-2023 Section 23.10.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the right-hand side of the defparam uses the parameter K of the instance w, which is declared in another module
:expected_stderr_regex: test_illegal_defparam_rhs_other_module_parameter\.sv:31:
*/
// IEEE 1800-2023 §23.10.1: the right-hand side of a defparam assignment
// shall be a constant expression of numbers and of parameters, and those
// parameters shall be declared in the same module as the defparam. K is a
// parameter of the module of the instance w, not of the top module, so the
// defparam may not use w.K.

module defparam_rhs_other_leaf;
  parameter int P = 0;
endmodule

module defparam_rhs_other_with_k;
  parameter int K = 3;
endmodule

module test_illegal_defparam_rhs_other_module_parameter;
  defparam_rhs_other_leaf u();
  defparam_rhs_other_with_k w();
  defparam u.P = w.K;   // illegal
endmodule
