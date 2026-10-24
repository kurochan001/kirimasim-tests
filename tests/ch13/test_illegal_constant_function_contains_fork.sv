/*
:name: test_illegal_constant_function_contains_fork
:description: a function that contains a fork construct cannot be called as a constant function (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f, called in the initial value of the localparam P, contains a fork-join_none construct
:expected_stderr_regex: test_illegal_constant_function_contains_fork\.sv:(31|41):
*/
// IEEE 1800-2023 §13.4.3: a constant function shall not contain any fork
// constructs. f contains an empty fork-join_none, which 13.4.4 allows in a
// function and which schedules nothing, so f may be called at run time, as the
// initial procedure does; its call in the initial value of P breaks only the
// rule of constant functions. h has the same body without the fork, so the
// call of h in the initial value of Q is legal.
// A function that breaks one of the constraints of a constant function is not
// one, and its call in the initial value of a localparam, which requires a
// constant expression (11.2.1), is then illegal; a tool can report the error at
// the call or at the line that breaks the constraint.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design.

module test_illegal_constant_function_contains_fork;
  function int h(input int a);
    return a + 1;
  endfunction
  function int f(input int a);
    fork
    join_none
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
