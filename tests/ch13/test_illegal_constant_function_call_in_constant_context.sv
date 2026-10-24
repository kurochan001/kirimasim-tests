/*
:name: test_illegal_constant_function_call_in_constant_context
:description: a constant function cannot call constant functions where a constant expression is required (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f, called in the initial value of the localparam P, calls the constant function g in the range of a local declaration
:expected_stderr_regex: test_illegal_constant_function_call_in_constant_context\.sv:(33|38):
*/
// IEEE 1800-2023 §13.4.3: a constant function shall not call constant
// functions in any context that requires a constant expression. g is a
// constant function. f calls it in the range of its local variable v, which
// requires a constant expression; h calls it in an ordinary expression, so the
// call of h in the initial value of Q is legal.
// A function that breaks one of the constraints of a constant function is not
// one, and its call in the initial value of a localparam, which requires a
// constant expression (11.2.1), is then illegal; a tool can report the error at
// the call or at the line that breaks the constraint.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design.

module test_illegal_constant_function_call_in_constant_context;
  function int g(input int a);
    return a + 1;
  endfunction
  function int h(input int a);
    return g(a) * 2;
  endfunction
  function int f(input int a);
    logic [g(6):0] v;
    v = a;
    return v;
  endfunction
  localparam int Q = h(2);
  localparam int P = f(5);   // illegal
  initial $display("%0d %0d", P, Q);
endmodule
