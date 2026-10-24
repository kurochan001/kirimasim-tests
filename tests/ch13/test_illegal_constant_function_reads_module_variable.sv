/*
:name: test_illegal_constant_function_reads_module_variable
:description: a constant function cannot reference a variable that is not declared in it (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f, called in the initial value of the localparam P, reads the module variable g
:expected_stderr_regex: test_illegal_constant_function_reads_module_variable\.sv:(33|36):
*/
// IEEE 1800-2023 §13.4.3: a constant function shall not reference any
// identifier that is not a parameter, a function name, or declared in the
// function itself. f reads the module variable g; h reads only its argument,
// its local variable and the parameter K, so the call of h in the initial
// value of Q is legal.
// A function that breaks one of the constraints of a constant function is not
// one, and its call in the initial value of a localparam, which requires a
// constant expression (11.2.1), is then illegal; a tool can report the error at
// the call or at the line that breaks the constraint.

module test_illegal_constant_function_reads_module_variable;
  localparam int K = 2;
  int g = 3;
  function int h(input int a);
    int t;
    t = a * K;
    return t;
  endfunction
  function int f(input int a);
    return a + g;
  endfunction
  localparam int Q = h(1);
  localparam int P = f(1);   // illegal
  initial $display("%0d %0d", P, Q);
endmodule
