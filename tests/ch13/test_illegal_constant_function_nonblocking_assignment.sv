/*
:name: test_illegal_constant_function_nonblocking_assignment
:description: a function that contains a nonblocking assignment, which schedules an update after the function returns, cannot be called as a constant function (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f, called in the initial value of the localparam P, contains a nonblocking assignment to its local variable t
:expected_stderr_regex: test_illegal_constant_function_nonblocking_assignment\.sv:(39|48):
*/
// IEEE 1800-2023 §13.4.3: a constant function shall not contain a statement
// that directly schedules an event to execute after the function has
// returned. f assigns its local variable t with a nonblocking assignment,
// whose update takes place after the call. §13.4.4 allows a nonblocking
// assignment in a function, and t is static, as f is declared in a module
// without a lifetime, so the call of f in the initial procedure is legal;
// only its call in the initial value of P breaks the rule of constant
// functions. h assigns t with a blocking assignment, so the call of h in the
// initial value of Q is legal. Without P the design prints "3 5".
// A function that breaks one of the constraints of a constant function is not
// one, and its call in the initial value of a localparam, which requires a
// constant expression (11.2.1), is then illegal; a tool can report the error at
// the call or at the statement that breaks the constraint.
// Icarus Verilog 13.0 rejects every nonblocking assignment in a function, at
// that line, so its error does not count; the 5.054 release of Verilator
// stops at the call on a limit of its evaluator, which does not count either.

module test_illegal_constant_function_nonblocking_assignment;
  function int h(input int a);
    int t;
    t = a;
    return t + 1;
  endfunction
  function int f(input int a);
    int t;
    t <= a;
    return a + 1;
  endfunction
  localparam int Q = h(2);
  int r;
  initial begin
    r = f(4);
    $display("%0d %0d", Q, r);
  end
  localparam int P = f(1);   // illegal
endmodule
