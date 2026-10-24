/*
:name: test_illegal_type_parameter_defparam
:description: a type parameter cannot be overridden with a defparam statement, while a value parameter can (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a defparam statement overrides the type parameter T of the instance u
:expected_stderr_regex: test_illegal_type_parameter_defparam\.sv:29:
*/
// IEEE 1800-2023 §6.20.3: it is illegal to override a type parameter with a
// defparam statement. The value parameter N of the instance u is overridden
// by a defparam statement, which is legal; the second defparam statement
// gives the type parameter T of the same instance the type shortint.
// Icarus Verilog 13.0 reports the rule; the other release reports a syntax
// error at the type, as a defparam statement takes a constant expression.

module test_illegal_type_parameter_defparam_m #(parameter int N = 1, parameter type T = int) ();
  T v;
  initial $display("%0d %0d", N, $bits(v));
endmodule

module test_illegal_type_parameter_defparam;
  test_illegal_type_parameter_defparam_m u();
  defparam u.N = 3;
  defparam u.T = shortint;   // illegal: defparam of a type parameter
endmodule
