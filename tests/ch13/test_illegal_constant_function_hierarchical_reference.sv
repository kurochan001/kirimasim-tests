/*
:name: test_illegal_constant_function_hierarchical_reference
:description: a constant function cannot contain a hierarchical reference (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f, called in the initial value of the localparam P, contains a hierarchical reference
:expected_stderr_regex: test_illegal_constant_function_hierarchical_reference\.sv:(29|32):
*/
// IEEE 1800-2023 §13.4.3: a constant function shall not contain any
// hierarchical references. f reads the parameter W through the hierarchical
// name of the module; g reads it by its simple name, which a constant function
// may do, so the call of g in the initial value of Q is legal.
// A function that breaks one of the constraints of a constant function is not
// one, and its call in the initial value of a localparam, which requires a
// constant expression (11.2.1), is then illegal; a tool can report the error at
// the call or at the line that breaks the constraint.

module test_illegal_constant_function_hierarchical_reference;
  localparam int W = 4;
  function int g(input int a);
    return a + W;
  endfunction
  function int f(input int a);
    return a + test_illegal_constant_function_hierarchical_reference.W;
  endfunction
  localparam int Q = g(1);
  localparam int P = f(1);   // illegal
  initial $display("%0d %0d", P, Q);
endmodule
