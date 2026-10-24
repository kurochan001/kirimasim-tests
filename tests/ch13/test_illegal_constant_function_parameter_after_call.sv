/*
:name: test_illegal_constant_function_parameter_after_call
:description: the parameters a constant function uses have to be defined before its call (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call of f in the initial value of the localparam P comes before the declaration of the parameter W that f uses
:expected_stderr_regex: test_illegal_constant_function_parameter_after_call\.sv:(28|31):
*/
// IEEE 1800-2023 §13.4.3: every parameter used in the evaluation of a constant
// function call shall be defined before the call, as such a use counts as a
// use at the place of the call; parameters of a package or $unit may be used.
// f reads W, which is declared before f but after the call of f in the
// initial value of P. g reads the package parameter pk::K, so the call of g in
// the initial value of Q is legal.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design.

package pk;
  parameter int K = 2;
endpackage

module test_illegal_constant_function_parameter_after_call;
  localparam int Q = g(1);
  localparam int P = f(1);   // illegal
  localparam int W = 4;
  function int f(input int a);
    return a + W;
  endfunction
  function int g(input int a);
    return a + pk::K;
  endfunction
  initial $display("%0d %0d", P, Q);
endmodule
