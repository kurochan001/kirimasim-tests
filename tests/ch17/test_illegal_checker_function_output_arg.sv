/*
:name: test_illegal_checker_function_output_arg
:description: A function called on the right-hand side of a checker variable assignment shall not have an output, inout or ref argument; a function with an input argument is allowed (IEEE 1800-2023 Section 17.8)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker assignment to yv calls f_out, whose formal argument is output
:expected_stderr_regex: test_illegal_checker_function_output_arg\.sv:36:
*/
// IEEE 1800-2023 §17.8: function calls on the right-hand side of checker
// variable assignments have the restrictions of function calls in concurrent
// assertions: no output, inout or ref arguments, although const ref is
// allowed. f_in has an input argument and is called in the assignment to zv,
// which is legal. f_out has an output argument and is called in the
// assignment to yv, which is illegal. A tool can report the error at the
// function declaration or at the call.

checker chk_fn(input int a, output int y, output int z);
  int t;
  int yv, zv;

  function automatic int f_in(input int i);
    return i + 1;
  endfunction

  function automatic int f_out(output int o);
    o = a;
    return o + 1;
  endfunction

  assign zv = f_in(a);
  assign yv = f_out(t);   // illegal: output argument in checker assignment
  assign y = yv;
  assign z = zv;
endchecker

module test_illegal_checker_function_output_arg;
  int a = 1;
  int y, z;

  chk_fn c(a, y, z);

  initial begin
    #1 $display("y=%0d z=%0d", y, z);
  end
endmodule
