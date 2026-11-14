/*
:name: test_illegal_function_name_redeclared_inside_function
:description: no object inside a function can be declared with the name of the function (IEEE 1800-2023 Section 13.4.1)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function doubled declares a local variable also named doubled
:expected_stderr_regex: test_illegal_function_name_redeclared_inside_function\.sv:(26|27):
*/
// IEEE 1800-2023 §13.4.1: a function implicitly declares, inside itself, a
// variable with its own name and its return type, and it is illegal to
// declare another object with the same name as the function inside the
// function scope. The function doubled declares the local variable doubled,
// which an ordinary nested scope would allow to hide the outer name. Without
// that declaration the design is legal: the assignment sets the implicit
// variable, which the function returns, and the call doubled(3) prints 6.
// A tool can report the error at the local variable or at the function.
// Icarus Verilog 13.0 accepts the design, and the 5.054 release of Verilator
// stops with an internal fault.

module test_illegal_function_name_redeclared_inside_function;
  function int doubled(input int a);
    int doubled;   // illegal: an object inside the function with its name
    doubled = 2 * a;
  endfunction
  initial $display("%0d", doubled(3));
endmodule
