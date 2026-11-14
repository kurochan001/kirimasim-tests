/*
:name: test_illegal_constant_function_nonconstant_default
:description: a function whose argument default is not a constant expression cannot be called as a constant function that uses the default (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call of f in the initial value of the localparam P leaves out b, whose default is the module variable g
:expected_stderr_regex: test_illegal_constant_function_nonconstant_default\.sv:(34|43):
*/
// IEEE 1800-2023 §13.4.3: a constant function may have default argument
// values, but each of them shall be a constant expression. The default of b
// in h is the literal 4, so the call h(1) in the initial value of Q is a
// constant function call that gives 5. The default of b in f is the module
// variable g; §13.5.3 evaluates it in the scope of the declaration at each
// call that uses it, so the call of f in the initial procedure is legal and
// gives 1 + 3 = 4, and only the call in the initial value of P, which also
// uses the default, breaks the rule of constant functions. Without P the
// design prints "5 4".
// A tool can report the error at the call or at the default.
// Icarus Verilog 13.0 reports at the default that a variable is not allowed
// in a constant expression (it also reports the call, as a call with a
// missing argument). The 5.054 release of Verilator reports at the call that
// it cannot evaluate f as a constant.

module test_illegal_constant_function_nonconstant_default;
  int g = 3;
  function int h(input int a, input int b = 4);
    return a + b;
  endfunction
  function int f(input int a, input int b = g);
    return a + b;
  endfunction
  localparam int Q = h(1);
  int r;
  initial begin
    r = f(1);
    $display("%0d %0d", Q, r);
  end
  localparam int P = f(1);   // illegal
endmodule
