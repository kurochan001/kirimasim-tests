/*
:name: test_illegal_parameter_value_from_variable
:description: a value parameter expression is limited to literals, parameters, localparams, genvars, enum names, package parameters and constant functions of them; a variable is not allowed (IEEE 1800-2023 Section 6.20.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the parameter BAD reads the variable count
:expected_stderr_regex: test_illegal_parameter_value_from_variable\.sv:38:
*/
// IEEE 1800-2023 §6.20.2: a value parameter can be assigned an expression of
// literals, value parameters, localparams, genvars, enum names and constant
// functions of these, and references to package items are allowed. The
// parameter ALL and the localparam G of the generate loop use each of these
// kinds; their values, 17 and 17 + 10 * g, are printed by the legal design.
// The parameter BAD reads the module variable count.

package test_illegal_parameter_value_from_variable_pkg;
  parameter int FROM_PKG = 7;
endpackage

module test_illegal_parameter_value_from_variable;
  typedef enum {E0, E1, E2} e_t;
  function automatic int twice(int x);
    return 2 * x;
  endfunction
  parameter int A = 3;
  localparam int B = A + 1;
  parameter int ALL = E2 + twice(B) + test_illegal_parameter_value_from_variable_pkg::FROM_PKG;
  for (genvar g = 0; g < 2; g++) begin : gen
    localparam int G = g * 10 + ALL;
    initial #(g) $display("%0d", G);
  end
  int count = 2;
  parameter int BAD = count + 1;   // illegal: a variable in a parameter value
endmodule
