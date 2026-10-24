/*
:name: test_illegal_parameter_value_hierarchical_name
:description: the expression of a value parameter cannot use a hierarchical name, even one that names a parameter of another instance (IEEE 1800-2023 Section 6.20.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the parameter BAD uses the hierarchical name sub.DEPTH
:expected_stderr_regex: test_illegal_parameter_value_hierarchical_name\.sv:29:
*/
// IEEE 1800-2023 §6.20.2: a value parameter can be given an expression of
// literals, parameters and localparams, genvars, enum names and constant
// functions of these, but hierarchical names are not allowed in it. OK uses
// an earlier parameter of the same module by its simple name; BAD reaches
// the parameter DEPTH of the instance sub through a hierarchical name.

module test_illegal_parameter_value_hierarchical_name_sub;
  parameter int DEPTH = 3;
endmodule

module test_illegal_parameter_value_hierarchical_name;
  test_illegal_parameter_value_hierarchical_name_sub sub();
  parameter int BASE = 4;
  parameter int OK = BASE + 1;
  initial $display("%0d", OK);
  parameter int BAD = sub.DEPTH + 1;   // illegal: hierarchical name
endmodule
